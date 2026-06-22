import '../../domain/entities/app_notification_entity.dart';
import '../../domain/repositories/app_notification_repository.dart';
import '../../../profile/data/datasources/profile_local_data_source.dart';
import '../../models/app_notification.dart';
import '../datasources/notification_local_data_source.dart';
import '../notification_provider.dart';

class AppNotificationRepositoryImpl implements AppNotificationRepository {
  AppNotificationRepositoryImpl({
    NotificationLocalDataSource? localDataSource,
    NotificationProvider? provider,
    ProfileLocalDataSource? profileLocalDataSource,
  }) : _localDataSource = localDataSource ?? NotificationLocalDataSource(),
       _provider = provider ?? NotificationProvider(),
       _profileLocalDataSource =
           profileLocalDataSource ?? ProfileLocalDataSource();

  final NotificationLocalDataSource _localDataSource;
  final NotificationProvider _provider;
  final ProfileLocalDataSource _profileLocalDataSource;

  @override
  Future<List<AppNotificationEntity>> getNotifications() async {
    final storedNotifications = await _localDataSource.getStoredNotifications();
    final notifications = await _filterEnabledNotifications(
      storedNotifications ?? const <AppNotification>[],
    );

    if (storedNotifications != null && notifications.length != storedNotifications.length) {
      await _persistNotifications(notifications);
    }

    return notifications;
  }

  @override
  Future<void> addNotification(AppNotificationEntity notification) async {
    await addNotificationIfNew(notification);
  }

  Future<AppNotification?> addNotificationIfNew(
    AppNotificationEntity notification,
  ) async {
    if (!await _isNotificationTypeEnabled(notification.type)) {
      return null;
    }

    final notifications = (await getNotifications()).cast<AppNotification>();
    final alreadyExists =
        notifications.any((item) => item.id == notification.id);
    if (alreadyExists) {
      return null;
    }

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

    final updated = [
      ...notifications,
      appNotification,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    await _persistNotifications(updated);
    return appNotification;
  }

  @override
  Future<void> markRead(String id) async {
    final notifications = (await getNotifications()).cast<AppNotification>();
    final updated = notifications
        .map(
          (notification) => notification.id == id && !notification.isRead
              ? notification.copyWith(readAt: DateTime.now())
              : notification,
        )
        .toList();

    await _persistNotifications(updated);

  }

  @override
  Future<void> markAllRead() async {
    final notifications = (await getNotifications()).cast<AppNotification>();
    final now = DateTime.now();
    final updated = notifications
        .map(
          (notification) => notification.isRead
              ? notification
              : notification.copyWith(readAt: now),
        )
        .toList();

    await _persistNotifications(updated);
  }

  @override
  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    final count =
        notifications.where((notification) => !notification.isRead).length;
    _provider.updateUnreadCount(count);
    return count;
  }

  @override
  Future<void> deleteNotification(String id) async {
    final notifications = (await getNotifications()).cast<AppNotification>();
    final updated =
        notifications.where((notification) => notification.id != id).toList();

    await _persistNotifications(updated);

  }

  @override
  Future<void> clearAllNotifications() async {
    await _persistNotifications(const <AppNotification>[]);
  }

  Future<void> deleteNotificationsByTypes(Set<String> types) async {
    if (types.isEmpty) {
      return;
    }

    final notifications = (await getNotifications()).cast<AppNotification>();
    final updated = notifications
        .where((notification) => !types.contains(notification.type))
        .toList();

    if (updated.length == notifications.length) {
      return;
    }

    await _persistNotifications(updated);
  }

  Future<void> deleteNotificationsByIds(Set<String> ids) async {
    if (ids.isEmpty) {
      return;
    }

    final notifications = (await getNotifications()).cast<AppNotification>();
    final updated = notifications
        .where((notification) => !ids.contains(notification.id))
        .toList();

    if (updated.length == notifications.length) {
      return;
    }

    await _persistNotifications(updated);
  }

  Future<void> _persistNotifications(List<AppNotification> notifications) async {
    await _localDataSource.persistNotifications(notifications);
    _provider.updateUnreadCount(
      notifications.where((notification) => !notification.isRead).length,
    );
  }

  Future<List<AppNotification>> _filterEnabledNotifications(
    List<AppNotification> notifications,
  ) async {
    if (notifications.isEmpty) {
      return notifications;
    }

    final enabledPrefs = await _fetchNotificationPrefs();
    return notifications.where((notification) {
      final preferenceKey = _preferenceKeyForType(notification.type);
      if (preferenceKey == null) {
        return true;
      }
      return enabledPrefs[preferenceKey] ?? true;
    }).toList();
  }

  Future<bool> _isNotificationTypeEnabled(String type) async {
    final preferenceKey = _preferenceKeyForType(type);
    if (preferenceKey == null) {
      return true;
    }

    final enabledPrefs = await _fetchNotificationPrefs();
    return enabledPrefs[preferenceKey] ?? true;
  }

  String? _preferenceKeyForType(String type) {
    switch (type) {
      case 'welcome':
        return ProfileLocalDataSource.notifyWelcomeKey;
      case 'risk_assessment':
        return ProfileLocalDataSource.notifyRiskAssessmentKey;
      case 'learning':
        return ProfileLocalDataSource.notifyLearningKey;
      case 'security':
        return ProfileLocalDataSource.notifySecurityKey;
      case 'reminder':
        return ProfileLocalDataSource.notifyInactivityKey;
      default:
        return null;
    }
  }

  Future<Map<String, bool>> _fetchNotificationPrefs() async {
    final prefs = await _profileLocalDataSource.getNotificationPreferences();
    return {
      ProfileLocalDataSource.notifyPushKey: prefs.pushEnabled,
      ProfileLocalDataSource.notifyWelcomeKey: prefs.welcome,
      ProfileLocalDataSource.notifySoundKey: prefs.sound,
      ProfileLocalDataSource.notifyInactivityKey: prefs.inactivity,
      ProfileLocalDataSource.notifyRiskAssessmentKey: prefs.riskAssessment,
      ProfileLocalDataSource.notifyLearningKey: prefs.learning,
      ProfileLocalDataSource.notifySecurityKey: prefs.security,
    };
  }
}
