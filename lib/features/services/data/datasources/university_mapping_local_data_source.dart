import '../../../../shared/data/offline_json_cache.dart';

class UniversityMappingLocalDataSource {
  static const String cacheKey = 'offline_cache_university_mappings';

  Future<void> cacheUniversityMappingsPayload(Map<String, dynamic> payload) {
    return OfflineJsonCache.saveMap(cacheKey, payload);
  }

  Future<Map<String, dynamic>?> getCachedUniversityMappingsPayload() {
    return OfflineJsonCache.readMap(cacheKey);
  }
}
