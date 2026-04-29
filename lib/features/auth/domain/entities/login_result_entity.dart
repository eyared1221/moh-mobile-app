import 'auth_user_entity.dart';

class LoginResultEntity {
  final String token;
  final AuthUserEntity user;

  const LoginResultEntity({
    required this.token,
    required this.user,
  });
}
