import 'auth_user_entity.dart';

class RegisterResultEntity {
  final AuthUserEntity user;
  final String message;
  final String? debugCode;

  const RegisterResultEntity({
    required this.user,
    required this.message,
    this.debugCode,
  });
}
