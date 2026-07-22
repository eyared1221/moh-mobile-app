import '../../data/auth_service.dart';
import '../../domain/entities/auth_action_result_entity.dart';
import '../../domain/entities/login_result_entity.dart';
import '../../domain/entities/register_result_entity.dart';
import '../../domain/usecases/change_password_use_case.dart';
import '../../domain/usecases/check_username_availability_use_case.dart';
import '../../domain/usecases/forgot_password_use_case.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/resend_otp_use_case.dart';
import '../../domain/usecases/reset_password_use_case.dart';
import '../../domain/usecases/verify_otp_use_case.dart';
import '../../domain/usecases/verify_reset_code_use_case.dart';

class AuthController {
  const AuthController({
    required RegisterUseCase registerUseCase,
    required LoginUseCase loginUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required ResendOtpUseCase resendOtpUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required VerifyResetCodeUseCase verifyResetCodeUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required CheckUsernameAvailabilityUseCase checkUsernameAvailabilityUseCase,
  }) : _registerUseCase = registerUseCase,
       _loginUseCase = loginUseCase,
       _verifyOtpUseCase = verifyOtpUseCase,
       _resendOtpUseCase = resendOtpUseCase,
       _forgotPasswordUseCase = forgotPasswordUseCase,
       _verifyResetCodeUseCase = verifyResetCodeUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _changePasswordUseCase = changePasswordUseCase,
       _checkUsernameAvailabilityUseCase = checkUsernameAvailabilityUseCase;

  factory AuthController.standard() {
    final repository = AuthService.instance;
    return AuthController(
      registerUseCase: RegisterUseCase(repository),
      loginUseCase: LoginUseCase(repository),
      verifyOtpUseCase: VerifyOtpUseCase(repository),
      resendOtpUseCase: ResendOtpUseCase(repository),
      forgotPasswordUseCase: ForgotPasswordUseCase(repository),
      verifyResetCodeUseCase: VerifyResetCodeUseCase(repository),
      resetPasswordUseCase: ResetPasswordUseCase(repository),
      changePasswordUseCase: ChangePasswordUseCase(repository),
      checkUsernameAvailabilityUseCase: CheckUsernameAvailabilityUseCase(
        repository,
      ),
    );
  }

  final RegisterUseCase _registerUseCase;
  final LoginUseCase _loginUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResendOtpUseCase _resendOtpUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final VerifyResetCodeUseCase _verifyResetCodeUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final CheckUsernameAvailabilityUseCase _checkUsernameAvailabilityUseCase;

  Future<RegisterResultEntity> register({
    required String email,
    required String username,
    required String phone,
    required int age,
    required String password,
  }) {
    return _registerUseCase(
      email: email,
      username: username,
      phone: phone,
      age: age,
      password: password,
    );
  }

  Future<LoginResultEntity> login({
    required String identifier,
    required String password,
  }) {
    return _loginUseCase(identifier: identifier, password: password);
  }

  Future<bool> isUsernameAvailable(String username) {
    return _checkUsernameAvailabilityUseCase(username);
  }

  Future<void> verifyOtp({required String contact, required String otp}) {
    return _verifyOtpUseCase(contact: contact, otp: otp);
  }

  Future<AuthActionResultEntity> resendOtp({required String contact}) {
    return _resendOtpUseCase(contact: contact);
  }

  Future<AuthActionResultEntity> forgotPassword({required String contact}) {
    return _forgotPasswordUseCase(contact: contact);
  }

  Future<void> verifyResetCode({
    required String contact,
    required String code,
  }) {
    return _verifyResetCodeUseCase(contact: contact, code: code);
  }

  Future<void> resetPassword({
    required String contact,
    required String code,
    required String password,
  }) {
    return _resetPasswordUseCase(
      contact: contact,
      code: code,
      password: password,
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return _changePasswordUseCase(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}
