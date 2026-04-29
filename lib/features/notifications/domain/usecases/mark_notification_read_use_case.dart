import '../repositories/app_notification_repository.dart';

class MarkNotificationReadUseCase {
  const MarkNotificationReadUseCase(this._repository);

  final AppNotificationRepository _repository;

  Future<void> call(String id) {
    return _repository.markRead(id);
  }
}
