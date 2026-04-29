import '../repositories/auth_repository.dart';

class VerifyResetCodeUseCase {
  const VerifyResetCodeUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String contact,
    required String code,
  }) {
    return _repository.verifyResetCode(
      contact: contact,
      code: code,
    );
  }
}
