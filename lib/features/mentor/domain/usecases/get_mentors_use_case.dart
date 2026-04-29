import '../entities/mentor_entity.dart';
import '../repositories/mentor_repository.dart';

class GetMentorsUseCase {
  const GetMentorsUseCase(this._repository);

  final MentorRepository _repository;

  Future<List<MentorEntity>> call() {
    return _repository.fetchMentors();
  }
}
