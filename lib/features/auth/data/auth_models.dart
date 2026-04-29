import '../domain/entities/auth_action_result_entity.dart';
import '../domain/entities/auth_user_entity.dart';
import '../domain/entities/login_result_entity.dart';
import '../domain/entities/register_result_entity.dart';

class AuthApiException implements Exception {
  final String message;

  const AuthApiException(this.message);

  @override
  String toString() => message;
}

class AuthActionResult extends AuthActionResultEntity {
  const AuthActionResult({
    required super.message,
    super.debugCode,
  });

  factory AuthActionResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};

    return AuthActionResult(
      message: json['message'] as String? ?? '',
      debugCode: data['debugCode'] as String?,
    );
  }
}

class AuthUser extends AuthUserEntity {
  const AuthUser({
    required super.id,
    required super.email,
    required super.phone,
    required super.username,
    required super.age,
    required super.ageGroup,
    required super.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      username: (json['username'] ?? json['name'] ?? '') as String,
      age: (json['age'] as num?)?.toInt() ?? 0,
      ageGroup: json['ageGroup'] as String? ?? '',
      role: json['role'] as String? ?? 'app_user',
    );
  }
}

class LoginResult extends LoginResultEntity {
  const LoginResult({
    required super.token,
    required AuthUser super.user,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      token: json['token'] as String? ?? '',
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>? ?? const {}),
    );
  }
}

class RegisterResult extends RegisterResultEntity {
  const RegisterResult({
    required AuthUser super.user,
    required super.message,
    super.debugCode,
  });

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};

    return RegisterResult(
      user: AuthUser.fromJson(data['user'] as Map<String, dynamic>? ?? const {}),
      message: json['message'] as String? ?? '',
      debugCode: data['debugCode'] as String?,
    );
  }
}
