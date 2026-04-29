import '../../../../shared/data/offline_json_cache.dart';

class RiskAssessmentLocalDataSource {
  static const String questionsCacheKey = 'offline_cache_risk_questions';

  Future<void> cacheQuestionsPayload(Map<String, dynamic> payload) {
    return OfflineJsonCache.saveMap(questionsCacheKey, payload);
  }

  Future<Map<String, dynamic>?> getCachedQuestionsPayload() {
    return OfflineJsonCache.readMap(questionsCacheKey);
  }
}
