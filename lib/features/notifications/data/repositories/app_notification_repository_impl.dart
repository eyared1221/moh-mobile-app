import '../../domain/entities/app_notification_entity.dart';
import '../../domain/repositories/app_notification_repository.dart';
import '../../models/app_notification.dart';
import '../datasources/notification_local_data_source.dart';
import '../notification_provider.dart';

class AppNotificationRepositoryImpl implements AppNotificationRepository {
  AppNotificationRepositoryImpl({
    NotificationLocalDataSource? localDataSource,
    NotificationProvider? provider,
  }) : _localDataSource = localDataSource ?? NotificationLocalDataSource(),
       _provider = provider ?? NotificationProvider();

  final NotificationLocalDataSource _localDataSource;
  final NotificationProvider _provider;

  @override
  Future<List<AppNotificationEntity>> getNotifications() async {
    var notifications = await _localDataSource.getStoredNotifications();
    if (notifications == null) {
      notifications = await _localDataSource.buildDefaultNotifications();
      await _localDataSource.persistNotifications(notifications);
    }

    return notifications;
  }

  @override
  Future<void> addNotification(AppNotificationEntity notification) async {
    final notifications = (await getNotifications()).cast<AppNotification>();
    final alreadyExists =
        notifications.any((item) => item.id == notification.id);
    if (alreadyExists) {
      return;
    }

    final updated = [
      ...notifications,
      notification is AppNotification
          ? notification
          : AppNotification(
              id: notification.id,
              type: notification.type,
              title: notification.title,
              message: notification.message,
              createdAt: notification.createdAt,
              readAt: notification.readAt,
            ),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    await _localDataSource.persistNotifications(updated);
    _provider.updateUnreadCount(updated.where((item) => !item.isRead).length);
  }

  @override
  Future<void> markRead(String id) async {
    final notifications = (await getNotifications()).cast<AppNotification>();
    final wasUnread = notifications.any((n) => n.id == id && !n.isRead);

    final updated = notifications
        .map(
          (notification) => notification.id == id && !notification.isRead
              ? notification.copyWith(readAt: DateTime.now())
              : notification,
        )
        .toList();

    await _localDataSource.persistNotifications(updated);

    if (wasUnread) {
      _provider.decrementUnreadCount();
    }
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

    await _localDataSource.persistNotifications(updated);
    _provider.resetUnreadCount();
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
    final wasUnread = notifications.any((n) => n.id == id && !n.isRead);
    final updated =
        notifications.where((notification) => notification.id != id).toList();

    await _localDataSource.persistNotifications(updated);

    if (wasUnread) {
      _provider.decrementUnreadCount();
    }
  }

  @override
  Future<void> clearAllNotifications() async {
    await _localDataSource.persistNotifications(const <AppNotification>[]);
    _provider.resetUnreadCount();
  }
}
