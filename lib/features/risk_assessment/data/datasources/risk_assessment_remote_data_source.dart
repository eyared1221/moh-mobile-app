import '../../models/risk_option.dart';
import '../../models/risk_question.dart';
import '../risk_assessment_api_client.dart';

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
