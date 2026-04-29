class AuthUserEntity {
  final String id;
  final String email;
  final String? phone;
  final String username;
  final int age;
  final String ageGroup;
  final String role;

  const AuthUserEntity({
    required this.id,
    required this.email,
    required this.phone,
    required this.username,
    required this.age,
    required this.ageGroup,
    required this.role,
  });
}
