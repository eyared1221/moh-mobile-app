class Mentor {
  final String id;
  final String fullName;
  final String phone;
  final String? imageUrl;
  final String? role;

  const Mentor({
    required this.id,
    required this.fullName,
    required this.phone,
    this.imageUrl,
    this.role,
  });

  factory Mentor.fromJson(Map<String, dynamic> json) {
    final fullName = (json['fullName'] ?? json['name'] ?? '').toString().trim();
    final phone = (json['phone'] ?? json['phoneNumber'] ?? '').toString().trim();
    final role = (json['professionalTitle'] ?? json['role'] ?? '').toString().trim();
    final imageUrl =
        (json['identificationImageUrl'] ??
                json['imageUrl'] ??
                json['avatarUrl'] ??
                '')
            .toString()
            .trim();

    return Mentor(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: fullName.isEmpty ? 'Mentor' : fullName,
      phone: phone.isEmpty ? 'Phone not available' : phone,
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
      role: role.isEmpty ? null : role,
    );
  }
}
