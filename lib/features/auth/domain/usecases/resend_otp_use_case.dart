import '../entities/auth_action_result_entity.dart';
import '../repositories/auth_repository.dart';

class ResendOtpUseCase {
  const ResendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthActionResultEntity> call({required String contact}) {
    return _repository.resendOtp(contact: contact);
  }
}
