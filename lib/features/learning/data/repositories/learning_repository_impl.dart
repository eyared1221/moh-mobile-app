import '../../domain/entities/learning_module_entity.dart';
import '../../domain/repositories/learning_repository.dart';
import '../datasources/learning_local_data_source.dart';
import '../datasources/learning_remote_data_source.dart';

class LearningRepositoryImpl implements LearningRepository {
  LearningRepositoryImpl({
    LearningRemoteDataSource? remoteDataSource,
    LearningLocalDataSource? localDataSource,
  }) : _remoteDataSource = remoteDataSource ?? LearningRemoteDataSource(),
       _localDataSource = localDataSource ?? LearningLocalDataSource();

  final LearningRemoteDataSource _remoteDataSource;
  final LearningLocalDataSource _localDataSource;

  @override
  Future<List<LearningModuleEntity>> getLearningModules() async {
    try {
      final payload = await _remoteDataSource.fetchModulesPayload();
      await _localDataSource.cacheModulesPayload(payload);
      return _remoteDataSource.mapModulesPayload(payload);
    } catch (e) {
      final cachedPayload = await _localDataSource.getCachedModulesPayload();
      if (cachedPayload != null) {
        return _remoteDataSource.mapModulesPayload(cachedPayload);
      }
      throw LearningRepositoryException('Failed to load learning modules: $e');
    }
  }

  @override
  Future<LearningModuleEntity> getLearningModuleBySlug(String slug) async {
    try {
      final payload = await _remoteDataSource.fetchModuleDetailPayload(slug);
      await _localDataSource.cacheModuleDetailPayload(slug, payload);
      return _remoteDataSource.mapModuleDetailPayload(payload);
    } catch (e) {
      final cachedDetailPayload = await _localDataSource
          .getCachedModuleDetailPayload(slug);
      if (cachedDetailPayload != null) {
        return _remoteDataSource.mapModuleDetailPayload(cachedDetailPayload);
      }

      final cachedModulesPayload = await _localDataSource
          .getCachedModulesPayload();
      if (cachedModulesPayload != null) {
        final modules = _remoteDataSource.mapModulesPayload(cachedModulesPayload);
        for (final module in modules) {
          if (module.id == slug) {
            return module;
          }
        }
      }

      throw LearningRepositoryException('Failed to load learning module: $e');
    }
  }
}

class LearningRepositoryException implements Exception {
  const LearningRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'LearningRepositoryException: $message';
}
