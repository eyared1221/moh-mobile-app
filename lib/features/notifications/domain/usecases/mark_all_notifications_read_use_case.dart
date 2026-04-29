import '../repositories/app_notification_repository.dart';

class MarkAllNotificationsReadUseCase {
  const MarkAllNotificationsReadUseCase(this._repository);

  final AppNotificationRepository _repository;

  Future<void> call() {
    return _repository.markAllRead();
  }
}
