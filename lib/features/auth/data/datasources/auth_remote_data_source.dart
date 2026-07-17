import '../auth_api_client.dart';
import '../auth_models.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({AuthApiClient? apiClient})
      : _apiClient = apiClient ?? AuthApiClient();

  final AuthApiClient _apiClient;

  Future<RegisterResult> register({
    required String email,
    required String username,
    required String phone,
    required int age,
    required String password,
  }) async {
    final payload = await _apiClient.post('/register', {
      'email': email,
      'username': username,
      'phone': phone,
      'age': age,
      'password': password,
    });

    return RegisterResult.fromJson(payload);
  }

  Future<LoginResult> login({
    required String identifier,
    required String password,
  }) async {
    final payload = await _apiClient.post('/login', {
      'identifier': identifier,
      'password': password,
    });

    return LoginResult.fromJson(
      payload['data'] as Map<String, dynamic>? ?? const {},
    );
  }

  Future<void> verifyOtp({
    required String contact,
    required String otp,
  }) async {
    await _apiClient.post('/verification?action=verify-otp', {
      'contact': contact,
      'otp': otp,
    });
  }

  Future<AuthActionResult> resendOtp({required String contact}) async {
    final payload = await _apiClient.post('/verification?action=resend-otp', {
      'contact': contact,
    });
    return AuthActionResult.fromJson(payload);
  }

  Future<AuthActionResult> forgotPassword({required String contact}) async {
    final payload = await _apiClient.post('/password?action=forgot', {
      'contact': contact,
    });
    return AuthActionResult.fromJson(payload);
  }

  Future<void> verifyResetCode({
    required String contact,
    required String code,
  }) async {
    await _apiClient.post('/password?action=verify-code', {
      'contact': contact,
      'code': code,
    });
  }

  Future<void> resetPassword({
    required String contact,
    required String code,
    required String password,
  }) async {
    await _apiClient.post('/password?action=reset', {
      'contact': contact,
      'code': code,
      'password': password,
    });
  }

  Future<void> changePassword({
    required String contact,
    required String oldPassword,
    required String newPassword,
  }) async {
    await _apiClient.post('/password?action=change', {
      'contact': contact,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }
}
