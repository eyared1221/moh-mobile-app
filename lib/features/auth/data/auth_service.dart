import 'repositories/auth_repository_impl.dart';

class AuthService extends AuthRepositoryImpl {
  AuthService({
    super.remoteDataSource,
    super.sessionLocalDataSource,
    super.deviceDataSource,
  });

  static final AuthService instance = AuthService();
}
