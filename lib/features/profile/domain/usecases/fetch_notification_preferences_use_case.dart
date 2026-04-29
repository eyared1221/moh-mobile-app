import '../entities/notification_preferences_entity.dart';
import '../repositories/profile_repository.dart';

class FetchNotificationPreferencesUseCase {
  const FetchNotificationPreferencesUseCase(this._repository);

  final ProfileRepository _repository;

  Future<NotificationPreferencesEntity> call() {
    return _repository.fetchNotificationPreferences();
  }
}
