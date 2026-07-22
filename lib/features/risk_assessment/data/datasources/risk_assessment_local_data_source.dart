import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/data/offline_json_cache.dart';

class RiskAssessmentLocalDataSource {
  static const String questionsCacheKey = 'offline_cache_risk_questions';
  static const String assessmentResultsCacheKey =
      'offline_cache_risk_assessment_results';
  static const int _maxStoredResults = 20;
  static const String anonymousProfileIdKey = 'anonymous_profile_id';
  static const String anonymousAccessTokenKey = 'anonymous_access_token';

  Future<void> cacheQuestionsPayload(Map<String, dynamic> payload) {
    return OfflineJsonCache.saveMap(questionsCacheKey, payload);
  }

  Future<Map<String, dynamic>?> getCachedQuestionsPayload() {
    return OfflineJsonCache.readMap(questionsCacheKey);
  }

  Future<bool> hasAuthenticatedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final token = prefs.getString('authToken')?.trim() ?? '';
    return isLoggedIn && token.isNotEmpty;
  }

  Future<AnonymousProfileCredentials?> getAnonymousProfileCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final profileId = prefs.getString(anonymousProfileIdKey)?.trim() ?? '';
    final accessToken = prefs.getString(anonymousAccessTokenKey)?.trim() ?? '';
    if (profileId.isEmpty || accessToken.isEmpty) return null;
    return AnonymousProfileCredentials(profileId, accessToken);
  }

  Future<void> saveAnonymousProfileCredentials(
    AnonymousProfileCredentials credentials,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await Future.wait([
      prefs.setString(anonymousProfileIdKey, credentials.profileId),
      prefs.setString(anonymousAccessTokenKey, credentials.accessToken),
    ]);
    if (saved.any((value) => !value)) {
      throw StateError('Could not persist anonymous profile credentials.');
    }
  }

  Future<void> saveAssessmentResult({
    required String riskLevel,
    required String resultLabel,
    required int riskScore,
    required DateTime takenAt,
    required String storageMode,
    required bool syncedToAccount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getSavedAssessmentResults();
    final entry = <String, dynamic>{
      'id': 'risk_${takenAt.millisecondsSinceEpoch}',
      'riskLevel': riskLevel,
      'resultLabel': resultLabel,
      'riskScore': riskScore,
      'takenAt': takenAt.toUtc().toIso8601String(),
      'storageMode': storageMode,
      'syncedToAccount': syncedToAccount,
      'savedAt': DateTime.now().toUtc().toIso8601String(),
    };

    final updated = <Map<String, dynamic>>[
      entry,
      ...existing,
    ];

    if (updated.length > _maxStoredResults) {
      updated.removeRange(_maxStoredResults, updated.length);
    }

    await prefs.setString(
      assessmentResultsCacheKey,
      jsonEncode(updated),
    );
  }

  Future<List<Map<String, dynamic>>> getSavedAssessmentResults() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(assessmentResultsCacheKey);
    if (raw == null || raw.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <Map<String, dynamic>>[];
      }

      return decoded
          .whereType<Map>()
          .map((item) => item.map((key, value) => MapEntry('$key', value)))
          .toList(growable: false);
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }
  }
}

class AnonymousProfileCredentials {
  const AnonymousProfileCredentials(this.profileId, this.accessToken);

  final String profileId;
  final String accessToken;
}
