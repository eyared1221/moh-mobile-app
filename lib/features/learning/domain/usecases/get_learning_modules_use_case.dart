import '../entities/learning_module_entity.dart';
import '../repositories/learning_repository.dart';

class GetLearningModulesUseCase {
  const GetLearningModulesUseCase(this._repository);

  final LearningRepository _repository;

  Future<List<LearningModuleEntity>> call() {
    return _repository.getLearningModules();
  }
}
