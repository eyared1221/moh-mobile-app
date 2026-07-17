import '../domain/entities/auth_action_result_entity.dart';
import '../domain/entities/login_result_entity.dart';
import '../domain/entities/register_result_entity.dart';
import 'datasources/auth_device_data_source.dart';
import 'datasources/auth_remote_data_source.dart';
import 'datasources/auth_session_local_data_source.dart';
import 'repositories/auth_repository_impl.dart';

class AuthService extends AuthRepositoryImpl {
  AuthService({
    super.remoteDataSource,
    super.sessionLocalDataSource,
    super.deviceDataSource,
  });

  static final AuthService instance = AuthService();

  @override
  Future<RegisterResultEntity> register({
    required String email,
    required String username,
    required String phone,
    required int age,
    required String password,
  }) {
    return super.register(
      email: email,
      username: username,
      phone: phone,
      age: age,
      password: password,
    );
  }

  @override
  Future<LoginResultEntity> login({
    required String identifier,
    required String password,
  }) {
    return super.login(
      identifier: identifier,
      password: password,
    );
  }

  @override
  Future<void> verifyOtp({
    required String contact,
    required String otp,
  }) {
    return super.verifyOtp(
      contact: contact,
      otp: otp,
    );
  }

  @override
  Future<AuthActionResultEntity> resendOtp({required String contact}) {
    return super.resendOtp(contact: contact);
  }

  @override
  Future<AuthActionResultEntity> forgotPassword({required String contact}) {
    return super.forgotPassword(contact: contact);
  }

  @override
  Future<void> verifyResetCode({
    required String contact,
    required String code,
  }) {
    return super.verifyResetCode(
      contact: contact,
      code: code,
    );
  }

  @override
  Future<void> resetPassword({
    required String contact,
    required String code,
    required String password,
  }) {
    return super.resetPassword(
      contact: contact,
      code: code,
      password: password,
    );
  }
}
