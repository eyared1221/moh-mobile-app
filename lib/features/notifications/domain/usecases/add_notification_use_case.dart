import '../entities/app_notification_entity.dart';
import '../repositories/app_notification_repository.dart';

class AddNotificationUseCase {
  const AddNotificationUseCase(this._repository);

  final AppNotificationRepository _repository;

  Future<void> call(AppNotificationEntity notification) {
    return _repository.addNotification(notification);
  }
}
