import '../entities/profile_user_entity.dart';
import '../repositories/profile_repository.dart';

class FetchProfileUseCase {
  const FetchProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileUserEntity> call({
    required int fallbackAge,
    String? fallbackName,
  }) {
    return _repository.fetchProfile(
      fallbackAge: fallbackAge,
      fallbackName: fallbackName,
    );
  }
}
