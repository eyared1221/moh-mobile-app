import '../repositories/app_notification_repository.dart';

class ClearAllNotificationsUseCase {
  const ClearAllNotificationsUseCase(this._repository);

  final AppNotificationRepository _repository;

  Future<void> call() {
    return _repository.clearAllNotifications();
  }
}
