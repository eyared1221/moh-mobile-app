import '../entities/auth_action_result_entity.dart';
import '../entities/login_result_entity.dart';
import '../entities/register_result_entity.dart';

abstract class AuthRepository {
  Future<RegisterResultEntity> register({
    required String email,
    required String username,
    required String phone,
    required int age,
    required String password,
  });

  Future<LoginResultEntity> login({
    required String identifier,
    required String password,
  });

  Future<void> verifyOtp({
    required String contact,
    required String otp,
  });

  Future<AuthActionResultEntity> resendOtp({required String contact});

  Future<AuthActionResultEntity> forgotPassword({required String contact});

  Future<void> verifyResetCode({
    required String contact,
    required String code,
  });

  Future<void> resetPassword({
    required String contact,
    required String code,
    required String password,
  });

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}
