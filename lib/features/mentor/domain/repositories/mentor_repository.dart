import '../entities/mentor_entity.dart';

abstract class MentorRepository {
  Future<List<MentorEntity>> fetchMentors();
}
