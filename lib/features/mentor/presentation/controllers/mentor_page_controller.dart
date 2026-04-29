import '../../domain/entities/mentor_entity.dart';
import '../../domain/usecases/get_mentors_use_case.dart';

class MentorPageController {
  const MentorPageController(this._getMentorsUseCase);

  final GetMentorsUseCase _getMentorsUseCase;

  Future<List<MentorEntity>> loadMentors() {
    return _getMentorsUseCase();
  }

  List<MentorEntity> filterMentors(List<MentorEntity> mentors, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return mentors;
    }

    return mentors.where((mentor) {
      final name = mentor.fullName.toLowerCase();
      final phone = mentor.phone.toLowerCase();
      return name.contains(normalized) || phone.contains(normalized);
    }).toList();
  }
}
