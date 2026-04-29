import '../entities/app_notification_entity.dart';
import '../repositories/app_notification_repository.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase(this._repository);

  final AppNotificationRepository _repository;

  Future<List<AppNotificationEntity>> call() {
    return _repository.getNotifications();
  }
}
