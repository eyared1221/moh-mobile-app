import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../firebase_options.dart';
import '../models/app_notification.dart';
import 'app_notification_service.dart';
import 'push_notification_api_client.dart';

const AndroidNotificationChannel _notificationChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'Used for Health Minister push notifications.',
  importance: Importance.max,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final options = DefaultFirebaseOptions.currentPlatform;
  if (options != null && Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: options);
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

  static final PushNotificationService instance = PushNotificationService();

  final FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final PushNotificationApiClient _apiClient;
  final AppNotificationService _appNotificationService;

  bool _isInitialized = false;

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
    if (options == null) {
      debugPrint(
        'PushNotificationService: Firebase options were not provided, skipping FCM setup.',
      );
      return;
    }

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: options);
    }

    final messaging = _messagingInstance;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initializeLocalNotifications();
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

    final registered = await syncRegistrationWithBackend(requestPermission: true);
    if (!registered) {
      await prefs.setBool(_pushEnabledKey, false);
      return false;
    }

    return true;
  }

  Future<bool> syncRegistrationWithBackend({
    required bool requestPermission,
  }) async {
    if (!isSupportedPlatform) {
      return false;
    }

    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        return false;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final pushEnabled = prefs.getBool(_pushEnabledKey) ?? true;

    if (!isLoggedIn || !pushEnabled) {
      return false;
    }

    final isAuthorized = await _ensurePermission(
      requestPermission: requestPermission,
    );
    if (!isAuthorized) {
      return false;
    }

    final token = await _messagingInstance.getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      await _registerToken(token);
      return true;
    } catch (error) {
      debugPrint('PushNotificationService: failed to register push token: $error');
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

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (details) async {
        if (details.payload == null || details.payload!.isEmpty) {
          return;
        }

        try {
          final payload = jsonDecode(details.payload!) as Map<String, dynamic>;
          await _appNotificationService.addNotification(
            AppNotification(
              id: payload['messageId']?.toString() ??
                  '${DateTime.now().millisecondsSinceEpoch}',
              type: payload['type']?.toString() ?? 'general',
              title: payload['title']?.toString() ?? 'New notification',
              message: payload['body']?.toString() ?? '',
              createdAt: DateTime.now(),
            ),
          );
        } catch (_) {
          // Keep notification taps non-fatal even if the payload is malformed.
        }
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_notificationChannel);
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

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await persistRemoteMessage(message);

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
        'messageId': message.messageId,
        'type': message.data['type'] ?? 'general',
        'title': notification.title,
        'body': notification.body,
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
}
