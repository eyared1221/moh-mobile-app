import '../entities/profile_user_entity.dart';
import '../repositories/profile_repository.dart';

class SaveProfileUseCase {
  const SaveProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileUserEntity> call(ProfileUserEntity user) {
    return _repository.saveProfile(user);
  }
}
