import '../entities/profile_user_entity.dart';
import '../repositories/profile_repository.dart';

class FetchCachedProfileUseCase {
  const FetchCachedProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileUserEntity?> call({
    required int fallbackAge,
    String? fallbackName,
  }) {
    return _repository.fetchCachedProfile(
      fallbackAge: fallbackAge,
      fallbackName: fallbackName,
    );
  }
}
