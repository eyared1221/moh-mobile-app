import '../repositories/app_notification_repository.dart';

class DeleteNotificationUseCase {
  const DeleteNotificationUseCase(this._repository);

  final AppNotificationRepository _repository;

  Future<void> call(String id) {
    return _repository.deleteNotification(id);
  }
}
