import '../domain/entities/mentor_entity.dart';

class MentorModel extends MentorEntity {
  const MentorModel({
    required super.id,
    required super.fullName,
    required super.phone,
    super.imageUrl,
    super.role,
  });

  factory MentorModel.fromJson(Map<String, dynamic> json) {
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

    return MentorModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: fullName.isEmpty ? 'Mentor' : fullName,
      phone: phone.isEmpty ? 'Phone not available' : phone,
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
      role: role.isEmpty ? null : role,
    );
  }
}
