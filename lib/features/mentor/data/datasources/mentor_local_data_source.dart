import '../../../../shared/data/offline_json_cache.dart';

class MentorLocalDataSource {
  static const String cacheKey = 'offline_cache_mentors';

  Future<void> cacheMentorPayload(Map<String, dynamic> payload) {
    return OfflineJsonCache.saveMap(cacheKey, payload);
  }

  Future<Map<String, dynamic>?> getCachedMentorPayload() {
    return OfflineJsonCache.readMap(cacheKey);
  }
}
