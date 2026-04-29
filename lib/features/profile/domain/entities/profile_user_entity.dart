class ProfileUserEntity {
  final String fullName;
  final int age;
  final String email;
  final String phone;
  final String language;
  final String? avatarPath;

  const ProfileUserEntity({
    required this.fullName,
    required this.age,
    required this.email,
    required this.phone,
    required this.language,
    this.avatarPath,
  });

  ProfileUserEntity copyWith({
    String? fullName,
    int? age,
    String? email,
    String? phone,
    String? language,
    String? avatarPath,
  }) {
    return ProfileUserEntity(
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      language: language ?? this.language,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
