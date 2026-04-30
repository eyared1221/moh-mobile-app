import '../domain/entities/app_notification_entity.dart';
import '../models/app_notification.dart';
import 'datasources/notification_local_data_source.dart';
import 'notification_provider.dart';
import 'repositories/app_notification_repository_impl.dart';

class AppNotificationService extends AppNotificationRepositoryImpl {
  AppNotificationService({
    NotificationLocalDataSource? localDataSource,
    NotificationProvider? provider,
  }) : super(
         localDataSource: localDataSource,
         provider: provider,
       );

  static final AppNotificationService instance = AppNotificationService();

  @override
  Future<List<AppNotificationEntity>> getNotifications() {
    return super.getNotifications();
  }

  @override
  Future<void> addNotification(AppNotificationEntity notification) {
    return super.addNotification(notification);
  }

  @override
  Future<void> markRead(String id) {
    return super.markRead(id);
  }

  @override
  Future<void> markAllRead() {
    return super.markAllRead();
  }

  @override
  Future<int> getUnreadCount() {
    return super.getUnreadCount();
  }

  @override
  Future<void> deleteNotification(String id) {
    return super.deleteNotification(id);
  }

  @override
  Future<void> clearAllNotifications() {
    return super.clearAllNotifications();
  }

  Future<void> deleteNotificationsByTypes(Set<String> types) {
    return super.deleteNotificationsByTypes(types);
  }

  Future<void> deleteNotificationsByIds(Set<String> ids) {
    return super.deleteNotificationsByIds(ids);
  }
}
