import '../domain/entities/mentor_entity.dart';
import 'repositories/mentor_repository_impl.dart';

class MentorRepository extends MentorRepositoryImpl {
  MentorRepository({
    super.remoteDataSource,
    super.localDataSource,
  });

  @override
  Future<List<MentorEntity>> fetchMentors() {
    return super.fetchMentors();
  }
}
