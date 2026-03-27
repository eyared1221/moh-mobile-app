class AuthApiException implements Exception {
  final String message;

  const AuthApiException(this.message);

  @override
  String toString() => message;
}

class AuthUser {
  final String id;
  final String email;
  final String? phone;
  final String username;
  final int age;
  final String ageGroup;
  final String role;

  const AuthUser({
    required this.id,
    required this.email,
    required this.phone,
    required this.username,
    required this.age,
    required this.ageGroup,
    required this.role,
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

class LoginResult {
  final String token;
  final AuthUser user;

  const LoginResult({
    required this.token,
    required this.user,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      token: json['token'] as String? ?? '',
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>? ?? const {}),
    );
  }
}

class RegisterResult {
  final AuthUser user;

  const RegisterResult({required this.user});

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    return RegisterResult(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>? ?? const {}),
    );
  }
}
