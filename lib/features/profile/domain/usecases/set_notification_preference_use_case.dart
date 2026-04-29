import '../repositories/profile_repository.dart';

class SetNotificationPreferenceUseCase {
  const SetNotificationPreferenceUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call(String key, bool value) {
    return _repository.setNotificationPreference(key, value);
  }
}
