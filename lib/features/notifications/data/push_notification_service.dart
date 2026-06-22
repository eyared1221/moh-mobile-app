import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../firebase_options.dart';
import '../../profile/data/datasources/profile_local_data_source.dart';
import '../domain/entities/app_notification_entity.dart';
import '../models/app_notification.dart';
import 'app_notification_service.dart';
import 'push_notification_api_client.dart';

const AndroidNotificationChannel _notificationChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'Used for Health Minister push notifications.',
  importance: Importance.max,
);

const AndroidNotificationChannel _silentNotificationChannel =
    AndroidNotificationChannel(
      'high_importance_silent_channel',
      'High Importance Silent Notifications',
      description: 'Used for silent local Health Minister notifications.',
      importance: Importance.max,
      playSound: false,
    );

class PushNotificationSetupException implements Exception {
  final String message;

  const PushNotificationSetupException(this.message);

  @override
  String toString() => message;
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final options = DefaultFirebaseOptions.currentPlatform;
  if (Firebase.apps.isEmpty) {
    if (options != null) {
      await Firebase.initializeApp(options: options);
    } else {
      await Firebase.initializeApp();
    }
  }

  await PushNotificationService.persistRemoteMessage(message);
}

AppNotification _toAppNotification(RemoteMessage message) {
  final data = message.data;
  final title = message.notification?.title ?? data['title'] ?? 'New notification';
  final body =
      message.notification?.body ??
      data['body'] ??
      data['message'] ??
      'Open the app to view more details.';

  return AppNotification(
    id: message.messageId ??
        '${message.sentTime?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}-${title.hashCode}',
    type: data['type'] ?? 'general',
    title: title,
    message: body,
    createdAt: message.sentTime ?? DateTime.now(),
  );
}

class PushNotificationService {
  PushNotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    PushNotificationApiClient? apiClient,
    AppNotificationService? appNotificationService,
  })  : _messaging = messaging,
        _localNotifications = localNotifications ?? FlutterLocalNotificationsPlugin(),
        _apiClient = apiClient ?? PushNotificationApiClient(),
        _appNotificationService =
            appNotificationService ?? AppNotificationService.instance;

  static const String _pushEnabledKey = 'notify_push_notifications';
  static const String _registeredTokenKey = 'registered_push_token';
  static const MethodChannel _deviceChannel = MethodChannel(
    'com.yegna_health/device',
  );

  static final PushNotificationService instance = PushNotificationService();

  final FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final PushNotificationApiClient _apiClient;
  final AppNotificationService _appNotificationService;

  bool _isInitialized = false;
  bool _localNotificationsInitialized = false;
  bool _timeZoneConfigured = false;

  static bool get isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  FirebaseMessaging get _messagingInstance => _messaging ?? FirebaseMessaging.instance;

  Future<void> initialize() async {
    if (_isInitialized || !isSupportedPlatform) {
      return;
    }

    final options = DefaultFirebaseOptions.currentPlatform;
    if (Firebase.apps.isEmpty) {
      try {
        if (options != null) {
          await Firebase.initializeApp(options: options);
        } else {
          // Fall back to the native Android/iOS Firebase config files when
          // dart-define values are not supplied for this build.
          await Firebase.initializeApp();
        }
      } catch (error) {
        debugPrint(
          'PushNotificationService: Firebase initialization failed: $error',
        );
        return;
      }
    }

    final messaging = _messagingInstance;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _ensureLocalNotificationsInitialized();
    await _configureLocalTimeZone();
    await _restoreNotificationFromLaunchDetails();
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    messaging.onTokenRefresh.listen(_handleTokenRefresh);

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      await persistRemoteMessage(initialMessage);
    }

    _isInitialized = true;
    try {
      await syncRegistrationWithBackend(requestPermission: false);
    } catch (error) {
      debugPrint('PushNotificationService: initial sync failed: $error');
    }
  }

  Future<bool> isPushEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pushEnabledKey) ?? true;
  }

  Future<bool> setPushEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushEnabledKey, enabled);

    if (!enabled) {
      await unregisterCurrentDevice(clearPreference: false);
      return false;
    }

    final registered = await syncRegistrationWithBackend(
      requestPermission: true,
      throwOnFailure: true,
    );
    if (!registered) {
      await prefs.setBool(_pushEnabledKey, false);
      return false;
    }

    return true;
  }

  Future<bool> syncRegistrationWithBackend({
    required bool requestPermission,
    bool throwOnFailure = false,
  }) async {
    if (!isSupportedPlatform) {
      if (throwOnFailure) {
        throw const PushNotificationSetupException(
          'Push notifications are only available on Android and iPhone.',
        );
      }
      return false;
    }

    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        if (throwOnFailure) {
          throw const PushNotificationSetupException(
            'Push notifications are not configured for this app build yet.',
          );
        }
        return false;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final pushEnabled = prefs.getBool(_pushEnabledKey) ?? true;

    if (!isLoggedIn) {
      if (throwOnFailure) {
        throw const PushNotificationSetupException(
          'You need to sign in again before enabling push notifications.',
        );
      }
      return false;
    }

    if (!pushEnabled) {
      return false;
    }

    final isAuthorized = await _ensurePermission(
      requestPermission: requestPermission,
    );
    if (!isAuthorized) {
      if (throwOnFailure) {
        throw const PushNotificationSetupException(
          'Notification permission was not granted for this device.',
        );
      }
      return false;
    }

    final token = await _messagingInstance.getToken();
    if (token == null || token.isEmpty) {
      if (throwOnFailure) {
        throw const PushNotificationSetupException(
          'This device could not get a Firebase push token.',
        );
      }
      return false;
    }

    try {
      await _registerToken(token);
      return true;
    } catch (error) {
      debugPrint('PushNotificationService: failed to register push token: $error');
      if (throwOnFailure) {
        if (error is Exception) {
          throw error;
        }
        throw const PushNotificationSetupException(
          'Failed to register this device for push notifications.',
        );
      }
      return false;
    }
  }

  Future<void> unregisterCurrentDevice({
    bool clearPreference = false,
  }) async {
    if (!isSupportedPlatform) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_registeredTokenKey);

    if (token != null && token.isNotEmpty) {
      try {
        await _apiClient.deletePushToken(token);
      } catch (error) {
        debugPrint('PushNotificationService: failed to delete push token: $error');
      }
    }

    await prefs.remove(_registeredTokenKey);
    if (clearPreference) {
      await prefs.setBool(_pushEnabledKey, false);
    }
  }

  static Future<void> persistRemoteMessage(RemoteMessage message) async {
    await AppNotificationService.instance.addNotification(_toAppNotification(message));
  }

  Future<void> showLocalAppNotification(
    AppNotificationEntity notification, {
    bool requestPermission = false,
  }) async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        return;
      }
    }

    if (!isSupportedPlatform) {
      return;
    }

    if (!await _canPresentLocalDeviceNotifications(
      requestPermission: requestPermission,
    )) {
      return;
    }

    final notificationPrefs = await ProfileLocalDataSource()
        .getNotificationPreferences();

    final appNotification =
        notification is AppNotification
            ? notification
            : AppNotification(
                id: notification.id,
                type: notification.type,
                title: notification.title,
                message: notification.message,
                createdAt: notification.createdAt,
                readAt: notification.readAt,
              );

    await _localNotifications.show(
      id: _notificationIdFor(appNotification.id),
      title: appNotification.title,
      body: appNotification.message,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          notificationPrefs.sound
              ? _notificationChannel.id
              : _silentNotificationChannel.id,
          notificationPrefs.sound
              ? _notificationChannel.name
              : _silentNotificationChannel.name,
          channelDescription: notificationPrefs.sound
              ? _notificationChannel.description
              : _silentNotificationChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: notificationPrefs.sound,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: notificationPrefs.sound,
        ),
      ),
      payload: jsonEncode({
        'notificationId': appNotification.id,
        'type': appNotification.type,
        'title': appNotification.title,
        'body': appNotification.message,
        'createdAt': appNotification.createdAt.toIso8601String(),
      }),
    );
  }

  Future<void> scheduleLocalAppNotification(
    AppNotificationEntity notification, {
    required DateTime scheduledAt,
    bool requestPermission = false,
  }) async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        return;
      }
    }

    if (!isSupportedPlatform) {
      return;
    }

    if (!await _canPresentLocalDeviceNotifications(
      requestPermission: requestPermission,
    )) {
      return;
    }

    await _configureLocalTimeZone();

    final notificationPrefs = await ProfileLocalDataSource()
        .getNotificationPreferences();
    final appNotification =
        notification is AppNotification
            ? notification
            : AppNotification(
                id: notification.id,
                type: notification.type,
                title: notification.title,
                message: notification.message,
                createdAt: notification.createdAt,
                readAt: notification.readAt,
              );
    final zonedScheduledAt = tz.TZDateTime.from(scheduledAt, tz.local);

    if (!zonedScheduledAt.isAfter(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await _localNotifications.zonedSchedule(
      id: _notificationIdFor(appNotification.id),
      scheduledDate: zonedScheduledAt,
      notificationDetails: _notificationDetailsForSound(
        notificationPrefs.sound,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: appNotification.title,
      body: appNotification.message,
      payload: jsonEncode({
        'notificationId': appNotification.id,
        'type': appNotification.type,
        'title': appNotification.title,
        'body': appNotification.message,
        'createdAt': appNotification.createdAt.toIso8601String(),
      }),
    );
  }

  Future<void> cancelLocalAppNotification(String notificationId) async {
    if (!isSupportedPlatform) {
      return;
    }

    await _ensureLocalNotificationsInitialized();
    await _localNotifications.cancel(id: _notificationIdFor(notificationId));
  }

  Future<void> _ensureLocalNotificationsInitialized() async {
    if (_localNotificationsInitialized || !isSupportedPlatform) {
      return;
    }

    await _initializeLocalNotifications();
    _localNotificationsInitialized = true;
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (details) async {
        await _restoreNotificationFromPayload(details.payload);
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_notificationChannel);
    await androidPlugin?.createNotificationChannel(_silentNotificationChannel);
  }

  Future<bool> _ensurePermission({
    required bool requestPermission,
  }) async {
    final messaging = _messagingInstance;
    var settings = await messaging.getNotificationSettings();

    if (requestPermission &&
        settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<bool> _canPresentLocalDeviceNotifications({
    required bool requestPermission,
  }) async {
    await _ensureLocalNotificationsInitialized();

    final prefs = await SharedPreferences.getInstance();
    final pushEnabled = prefs.getBool(_pushEnabledKey) ?? true;
    if (!pushEnabled) {
      return false;
    }

    return _ensurePermission(requestPermission: requestPermission);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final appNotification = _toAppNotification(message);
    await _appNotificationService.addNotification(appNotification);

    final notification = message.notification;
    if (notification == null) {
      return;
    }

    final id = message.messageId?.hashCode.abs() ??
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _localNotifications.show(
      id: id,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _notificationChannel.id,
          _notificationChannel.name,
          channelDescription: _notificationChannel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode({
        'notificationId': appNotification.id,
        'messageId': message.messageId,
        'type': message.data['type'] ?? 'general',
        'title': notification.title,
        'body': notification.body,
        'createdAt': appNotification.createdAt.toIso8601String(),
      }),
    );
  }

  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    await persistRemoteMessage(message);
  }

  Future<void> _handleTokenRefresh(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final pushEnabled = prefs.getBool(_pushEnabledKey) ?? true;

    if (!isLoggedIn || !pushEnabled) {
      return;
    }

    await _registerToken(token);
  }

  Future<void> _registerToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final previouslyRegisteredToken = prefs.getString(_registeredTokenKey);
    final packageInfo = await PackageInfo.fromPlatform();
    final locale = WidgetsBinding.instance.platformDispatcher.locale;

    if (previouslyRegisteredToken != null &&
        previouslyRegisteredToken.isNotEmpty &&
        previouslyRegisteredToken != token) {
      try {
        await _apiClient.deletePushToken(previouslyRegisteredToken);
      } catch (_) {
        // The backend also cleans up invalid tokens while sending.
      }
    }

    await _apiClient.registerPushToken({
      'token': token,
      'platform': defaultTargetPlatform.name,
      'deviceName': defaultTargetPlatform.name,
      'appVersion': packageInfo.version,
      'locale': locale.toLanguageTag(),
      'enabled': true,
    });

    await prefs.setString(_registeredTokenKey, token);
  }

  Future<void> _configureLocalTimeZone() async {
    if (_timeZoneConfigured || !isSupportedPlatform) {
      return;
    }

    tz.initializeTimeZones();

    try {
      final timeZoneName = await _deviceChannel.invokeMethod<String>(
        'getLocalTimeZone',
      );
      if (timeZoneName != null && timeZoneName.isNotEmpty) {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } else {
        tz.setLocalLocation(tz.UTC);
      }
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    _timeZoneConfigured = true;
  }

  Future<void> _restoreNotificationFromLaunchDetails() async {
    final launchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    if (!(launchDetails?.didNotificationLaunchApp ?? false)) {
      return;
    }

    await _restoreNotificationFromPayload(
      launchDetails?.notificationResponse?.payload,
    );
  }

  Future<void> _restoreNotificationFromPayload(String? payload) async {
    if (payload == null || payload.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      final createdAt = DateTime.tryParse(
            decoded['createdAt']?.toString() ?? '',
          ) ??
          DateTime.now();

      await _appNotificationService.addNotification(
        AppNotification(
          id: decoded['notificationId']?.toString() ??
              decoded['messageId']?.toString() ??
              '${DateTime.now().millisecondsSinceEpoch}',
          type: decoded['type']?.toString() ?? 'general',
          title: decoded['title']?.toString() ?? 'New notification',
          message: decoded['body']?.toString() ?? '',
          createdAt: createdAt,
        ),
      );
    } catch (_) {
      // Keep notification taps non-fatal even if the payload is malformed.
    }
  }

  NotificationDetails _notificationDetailsForSound(bool soundEnabled) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        soundEnabled ? _notificationChannel.id : _silentNotificationChannel.id,
        soundEnabled
            ? _notificationChannel.name
            : _silentNotificationChannel.name,
        channelDescription: soundEnabled
            ? _notificationChannel.description
            : _silentNotificationChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        playSound: soundEnabled,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: soundEnabled,
      ),
    );
  }

  int _notificationIdFor(String notificationId) {
    return notificationId.hashCode & 0x7fffffff;
  }
}
