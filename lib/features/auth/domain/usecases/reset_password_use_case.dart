import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String contact,
    required String code,
    required String password,
  }) {
    return _repository.resetPassword(
      contact: contact,
      code: code,
      password: password,
    );
  }
}
