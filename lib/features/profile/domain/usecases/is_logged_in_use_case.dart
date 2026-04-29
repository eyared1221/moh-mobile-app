import '../repositories/profile_repository.dart';

class IsLoggedInUseCase {
  const IsLoggedInUseCase(this._repository);

  final ProfileRepository _repository;

  Future<bool> call() {
    return _repository.isLoggedIn();
  }
}
