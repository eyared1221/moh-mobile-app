import '../domain/entities/learning_module_entity.dart';
import 'datasources/learning_local_data_source.dart';
import 'datasources/learning_remote_data_source.dart';
import 'repositories/learning_repository_impl.dart';

class LearningService extends LearningRepositoryImpl {
  LearningService({
    super.remoteDataSource,
    super.localDataSource,
  });

  static final LearningService instance = LearningService();

  @override
  Future<List<LearningModuleEntity>> getLearningModules() {
    return super.getLearningModules();
  }

  @override
  Future<LearningModuleEntity> getLearningModuleBySlug(String slug) {
    return super.getLearningModuleBySlug(slug);
  }
}
