import '../../domain/entities/login_result_entity.dart';
import '../auth_session_storage.dart';

class AuthSessionLocalDataSource {
  AuthSessionLocalDataSource({AuthSessionStorage? storage})
      : _storage = storage ?? AuthSessionStorage();

  final AuthSessionStorage _storage;

  Future<void> saveLogin(LoginResultEntity result) {
    return _storage.saveLogin(result);
  }
}
