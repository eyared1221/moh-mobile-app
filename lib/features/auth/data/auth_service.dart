import 'auth_api_client.dart';
import 'auth_models.dart';
import 'auth_session_storage.dart';

class AuthService {
  AuthService({
    AuthApiClient? apiClient,
    AuthSessionStorage? sessionStorage,
  })  : _apiClient = apiClient ?? AuthApiClient(),
        _sessionStorage = sessionStorage ?? AuthSessionStorage();

  final AuthApiClient _apiClient;
  final AuthSessionStorage _sessionStorage;

  static final AuthService instance = AuthService();

  Future<RegisterResult> register({
    required String contact,
    required String username,
    required int age,
    required String password,
  }) async {
    final payload = await _apiClient.post('/register', {
      'contact': contact,
      'username': username,
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

    final result = LoginResult.fromJson(payload['data'] as Map<String, dynamic>? ?? const {});
    await _sessionStorage.saveLogin(result);
    return result;
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
}
