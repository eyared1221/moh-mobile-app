import '../entities/app_notification_entity.dart';

abstract class AppNotificationRepository {
  Future<List<AppNotificationEntity>> getNotifications();

  Future<void> addNotification(AppNotificationEntity notification);

  Future<void> markRead(String id);

  Future<void> markAllRead();

  Future<int> getUnreadCount();

  Future<void> deleteNotification(String id);

  Future<void> clearAllNotifications();
}
