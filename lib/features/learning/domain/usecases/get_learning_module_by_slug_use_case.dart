import '../entities/learning_module_entity.dart';
import '../repositories/learning_repository.dart';

class GetLearningModuleBySlugUseCase {
  const GetLearningModuleBySlugUseCase(this._repository);

  final LearningRepository _repository;

  Future<LearningModuleEntity> call(String slug) {
    return _repository.getLearningModuleBySlug(slug);
  }
}
