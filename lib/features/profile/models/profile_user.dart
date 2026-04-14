class ProfileUser {
  final String fullName;
  final int age;
  final String email;
  final String phone;
  final String language;
  final String? avatarPath;

  const ProfileUser({
    required this.fullName,
    required this.age,
    required this.email,
    required this.phone,
    required this.language,
    this.avatarPath,
  });

  ProfileUser copyWith({
    String? fullName,
    int? age,
    String? email,
    String? phone,
    String? language,
    String? avatarPath,
  }) {
    return ProfileUser(
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      language: language ?? this.language,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    final language = (json['language'] ?? '').toString().trim();

    return ProfileUser(
      fullName:
          (json['full_name'] ?? json['fullName'] ?? json['username'] ?? json['name'] ?? '')
              .toString(),
      age: int.tryParse((json['age'] ?? 0).toString()) ?? 0,
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      language: language.isEmpty ? 'English' : language,
      avatarPath: json['avatar_path']?.toString() ?? json['avatarPath']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'age': age,
      'email': email,
      'phone': phone,
      'language': language,
      'avatar_path': avatarPath,
    };
  }
}
