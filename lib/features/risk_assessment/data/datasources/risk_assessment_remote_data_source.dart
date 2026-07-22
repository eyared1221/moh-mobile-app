import '../../models/risk_option.dart';
import '../../models/risk_question.dart';
import '../risk_assessment_api_client.dart';
import 'risk_assessment_local_data_source.dart';

class RiskAssessmentRemoteDataSource {
  RiskAssessmentRemoteDataSource({RiskAssessmentApiClient? apiClient})
      : _apiClient = apiClient ?? RiskAssessmentApiClient();

  final RiskAssessmentApiClient _apiClient;

  Future<Map<String, dynamic>> fetchQuestionsPayload() {
    return _apiClient.get('/questions');
  }

  Future<void> submitLatestResult({
    required String riskLevel,
    required String resultLabel,
    required int riskScore,
    required DateTime takenAt,
  }) async {
    await _apiClient.postAuthorizedToMobileAuth('/risk-assessment', {
      'riskLevel': riskLevel,
      'resultLabel': resultLabel,
      'riskScore': riskScore,
      'takenAt': takenAt.toUtc().toIso8601String(),
    });
  }

  Future<void> submitAnonymousResult({
    required AnonymousProfileCredentials credentials,
    required String riskLevel,
    required String resultLabel,
    required int riskScore,
    required DateTime takenAt,
  }) async {
    await _apiClient.post('/responses/anonymous', {
      'riskLevel': riskLevel,
      'resultLabel': resultLabel,
      'riskScore': riskScore,
      'takenAt': takenAt.toUtc().toIso8601String(),
    }, headers: {
      'x-anonymous-profile-id': credentials.profileId,
      'x-anonymous-access-token': credentials.accessToken,
    });
  }

  Future<AnonymousProfileCredentials> createAnonymousProfile() async {
    final payload = await _apiClient.post('/anonymous-profiles', const {});
    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      throw const RiskAssessmentApiException('Invalid anonymous profile response.');
    }

    final profileId = data['anonymousProfileId']?.toString() ?? '';
    final accessToken = data['anonymousAccessToken']?.toString() ?? '';
    if (profileId.isEmpty || accessToken.isEmpty) {
      throw const RiskAssessmentApiException('Invalid anonymous profile credentials.');
    }
    return AnonymousProfileCredentials(profileId, accessToken);
  }

  List<RiskQuestion> mapPayloadToQuestions(Map<String, dynamic> payload) {
    final rawItems = payload['data'];

    if (rawItems is! List) {
      throw const RiskAssessmentApiException(
        'Unexpected assessment question payload',
      );
    }

    return rawItems
        .whereType<Map<String, dynamic>>()
        .map(_mapQuestion)
        .where((question) => question.active && question.title.trim().isNotEmpty)
        .toList(growable: false);
  }

  RiskQuestion _mapQuestion(Map<String, dynamic> item) {
    final type = item['type']?.toString() ?? 'yesno';
    final rawOptions = item['options'];

    final optionLabels = rawOptions is List
        ? rawOptions
            .whereType<String>()
            .map((label) => label.trim())
            .where((label) => label.isNotEmpty)
            .toList()
        : <String>[];

    final resolvedOptionLabels = optionLabels.isNotEmpty
        ? optionLabels
        : (type == 'yesno' ? const ['Yes', 'No'] : const <String>[]);

    return RiskQuestion(
      id: item['id']?.toString() ?? '',
      number: item['number'] is num ? (item['number'] as num).toInt() : null,
      title: item['text']?.toString() ?? '',
      helper: '',
      type: type,
      active: item['active'] is bool ? item['active'] as bool : true,
      options: resolvedOptionLabels
          .map((label) => RiskOption(label: label))
          .toList(growable: false),
    );
  }
}
