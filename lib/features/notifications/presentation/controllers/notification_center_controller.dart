import '../../domain/entities/app_notification_entity.dart';
import '../../domain/usecases/clear_all_notifications_use_case.dart';
import '../../domain/usecases/delete_notification_use_case.dart';
import '../../domain/usecases/get_notifications_use_case.dart';
import '../../domain/usecases/mark_all_notifications_read_use_case.dart';
import '../../domain/usecases/mark_notification_read_use_case.dart';

class NotificationCenterController {
  const NotificationCenterController({
    required GetNotificationsUseCase getNotificationsUseCase,
    required MarkAllNotificationsReadUseCase markAllReadUseCase,
    required MarkNotificationReadUseCase markReadUseCase,
    required DeleteNotificationUseCase deleteNotificationUseCase,
    required ClearAllNotificationsUseCase clearAllNotificationsUseCase,
  }) : _getNotificationsUseCase = getNotificationsUseCase,
       _markAllReadUseCase = markAllReadUseCase,
       _markReadUseCase = markReadUseCase,
       _deleteNotificationUseCase = deleteNotificationUseCase,
       _clearAllNotificationsUseCase = clearAllNotificationsUseCase;

  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkAllNotificationsReadUseCase _markAllReadUseCase;
  final MarkNotificationReadUseCase _markReadUseCase;
  final DeleteNotificationUseCase _deleteNotificationUseCase;
  final ClearAllNotificationsUseCase _clearAllNotificationsUseCase;

  Future<List<AppNotificationEntity>> loadNotifications() {
    return _getNotificationsUseCase();
  }

  Future<void> markAllRead() {
    return _markAllReadUseCase();
  }

  Future<void> openNotification(AppNotificationEntity notification) async {
    if (!notification.isRead) {
      await _markReadUseCase(notification.id);
    }
  }

  Future<void> deleteNotification(String id) {
    return _deleteNotificationUseCase(id);
  }

  Future<void> clearAllNotifications() {
    return _clearAllNotificationsUseCase();
  }
}
