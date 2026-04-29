import '../../../../shared/data/offline_json_cache.dart';

class ClinicLocalDataSource {
  static const String cacheKey = 'offline_cache_clinics';

  Future<void> cacheClinicsPayload(Map<String, dynamic> payload) {
    return OfflineJsonCache.saveMap(cacheKey, payload);
  }

  Future<Map<String, dynamic>?> getCachedClinicsPayload() {
    return OfflineJsonCache.readMap(cacheKey);
  }
}
