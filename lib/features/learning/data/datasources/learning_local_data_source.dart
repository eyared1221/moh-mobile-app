import '../../../../shared/data/offline_json_cache.dart';

class LearningLocalDataSource {
  static const String modulesCacheKey = 'offline_cache_learning_modules';
  static const String moduleDetailCachePrefix = 'offline_cache_learning_module_';

  Future<void> cacheModulesPayload(Map<String, dynamic> payload) {
    return OfflineJsonCache.saveMap(modulesCacheKey, payload);
  }

  Future<Map<String, dynamic>?> getCachedModulesPayload() {
    return OfflineJsonCache.readMap(modulesCacheKey);
  }

  Future<void> cacheModuleDetailPayload(
    String slug,
    Map<String, dynamic> payload,
  ) {
    return OfflineJsonCache.saveMap(_moduleDetailCacheKey(slug), payload);
  }

  Future<Map<String, dynamic>?> getCachedModuleDetailPayload(String slug) {
    return OfflineJsonCache.readMap(_moduleDetailCacheKey(slug));
  }

  String _moduleDetailCacheKey(String slug) => '$moduleDetailCachePrefix$slug';
}
