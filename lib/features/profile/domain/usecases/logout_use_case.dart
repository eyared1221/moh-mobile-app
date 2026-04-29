import '../repositories/profile_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call() {
    return _repository.logout();
  }
}
