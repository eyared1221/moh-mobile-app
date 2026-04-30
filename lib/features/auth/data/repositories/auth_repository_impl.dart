import '../../domain/entities/auth_action_result_entity.dart';
import '../../domain/entities/login_result_entity.dart';
import '../../domain/entities/register_result_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../notifications/data/notification_automation_service.dart';
import '../datasources/auth_device_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_session_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
    AuthSessionLocalDataSource? sessionLocalDataSource,
    AuthDeviceDataSource? deviceDataSource,
  }) : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource(),
       _sessionLocalDataSource =
           sessionLocalDataSource ?? AuthSessionLocalDataSource(),
       _deviceDataSource = deviceDataSource ?? AuthDeviceDataSource();

  final AuthRemoteDataSource _remoteDataSource;
  final AuthSessionLocalDataSource _sessionLocalDataSource;
  final AuthDeviceDataSource _deviceDataSource;

  @override
  Future<RegisterResultEntity> register({
    required String contact,
    required String username,
    required int age,
    required String password,
  }) {
    return _remoteDataSource.register(
      contact: contact,
      username: username,
      age: age,
      password: password,
    );
  }

  @override
  Future<LoginResultEntity> login({
    required String identifier,
    required String password,
  }) async {
    final result = await _remoteDataSource.login(
      identifier: identifier,
      password: password,
    );

    await _sessionLocalDataSource.saveLogin(result);

    try {
      await _deviceDataSource.syncPushRegistration();
    } catch (_) {
      // Push registration should not block a successful sign-in.
    }

    await NotificationAutomationService.instance.handleSuccessfulSignIn(
      userName: result.user.username,
    );

    return result;
  }

  @override
  Future<void> verifyOtp({
    required String contact,
    required String otp,
  }) {
    return _remoteDataSource.verifyOtp(
      contact: contact,
      otp: otp,
    );
  }

  @override
  Future<AuthActionResultEntity> resendOtp({required String contact}) {
    return _remoteDataSource.resendOtp(contact: contact);
  }

  @override
  Future<AuthActionResultEntity> forgotPassword({required String contact}) {
    return _remoteDataSource.forgotPassword(contact: contact);
  }

  @override
  Future<void> verifyResetCode({
    required String contact,
    required String code,
  }) {
    return _remoteDataSource.verifyResetCode(
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
    return _remoteDataSource.resetPassword(
      contact: contact,
      code: code,
      password: password,
    );
  }
}
