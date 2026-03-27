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

    return RegisterResult.fromJson(payload['data'] as Map<String, dynamic>? ?? const {});
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
    required String email,
    required String otp,
  }) async {
    await _apiClient.post('/verification?action=verify-otp', {
      'email': email,
      'otp': otp,
    });
  }

  Future<void> resendOtp({required String email}) async {
    await _apiClient.post('/verification?action=resend-otp', {
      'email': email,
    });
  }

  Future<void> forgotPassword({required String email}) async {
    await _apiClient.post('/password?action=forgot', {
      'email': email,
    });
  }

  Future<void> verifyResetCode({
    required String email,
    required String code,
  }) async {
    await _apiClient.post('/password?action=verify-code', {
      'email': email,
      'code': code,
    });
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    await _apiClient.post('/password?action=reset', {
      'email': email,
      'code': code,
      'password': password,
    });
  }
}
