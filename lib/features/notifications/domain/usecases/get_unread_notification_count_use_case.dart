import '../repositories/app_notification_repository.dart';

class GetUnreadNotificationCountUseCase {
  const GetUnreadNotificationCountUseCase(this._repository);

  final AppNotificationRepository _repository;

  Future<int> call() {
    return _repository.getUnreadCount();
  }
}
