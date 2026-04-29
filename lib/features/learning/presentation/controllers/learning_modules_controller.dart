import '../../domain/entities/learning_module_entity.dart';
import '../../domain/usecases/get_learning_modules_use_case.dart';

class LearningModulesController {
  const LearningModulesController(this._getLearningModulesUseCase);

  final GetLearningModulesUseCase _getLearningModulesUseCase;

  Future<List<LearningModuleEntity>> loadModules() {
    return _getLearningModulesUseCase();
  }
}
