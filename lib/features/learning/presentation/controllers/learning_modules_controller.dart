import '../../data/datasources/learning_local_data_source.dart';
import '../../data/datasources/learning_remote_data_source.dart';
import '../../domain/entities/learning_module_entity.dart';
import '../../domain/usecases/get_learning_modules_use_case.dart';

class LearningModulesController {
  LearningModulesController(
    this._getLearningModulesUseCase, {
    LearningLocalDataSource? localDataSource,
    LearningRemoteDataSource? remoteDataSource,
  }) : _localDataSource = localDataSource ?? LearningLocalDataSource(),
       _remoteDataSource = remoteDataSource ?? LearningRemoteDataSource();

  final GetLearningModulesUseCase _getLearningModulesUseCase;
  final LearningLocalDataSource _localDataSource;
  final LearningRemoteDataSource _remoteDataSource;

  Future<List<LearningModuleEntity>> loadModules() {
    return _getLearningModulesUseCase();
  }

  Future<List<LearningModuleEntity>> loadCachedModules() async {
    final cachedPayload = await _localDataSource.getCachedModulesPayload();
    if (cachedPayload == null) {
      return const <LearningModuleEntity>[];
    }

    try {
      return _remoteDataSource.mapModulesPayload(cachedPayload);
    } catch (_) {
      return const <LearningModuleEntity>[];
    }
  }
}
