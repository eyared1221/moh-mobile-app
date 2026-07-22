class MentorEntity {
  final String id;
  final String fullName;
  final String phone;
  final String? imageUrl;
  final String? role;
  final String? assignedArea;

  const MentorEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    this.imageUrl,
    this.role,
    this.assignedArea,
  });
}
