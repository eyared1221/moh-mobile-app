import '../repositories/profile_repository.dart';

class SetPushEnabledUseCase {
  const SetPushEnabledUseCase(this._repository);

  final ProfileRepository _repository;

  Future<bool> call(bool enabled) {
    return _repository.setPushEnabled(enabled);
  }
}
