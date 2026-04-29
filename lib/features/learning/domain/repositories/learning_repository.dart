import '../entities/learning_module_entity.dart';

abstract class LearningRepository {
  Future<List<LearningModuleEntity>> getLearningModules();
  Future<LearningModuleEntity> getLearningModuleBySlug(String slug);
}
