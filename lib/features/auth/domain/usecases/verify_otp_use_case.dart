import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String contact,
    required String otp,
  }) {
    return _repository.verifyOtp(
      contact: contact,
      otp: otp,
    );
  }
}
