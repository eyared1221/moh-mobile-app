import '../../data/datasources/risk_assessment_local_data_source.dart';
import '../../data/datasources/risk_assessment_remote_data_source.dart';
import '../../domain/entities/risk_question_entity.dart';
import '../../domain/usecases/get_risk_assessment_questions_use_case.dart';

class RiskAssessmentPageController {
  RiskAssessmentPageController(
    this._getQuestionsUseCase, {
    RiskAssessmentLocalDataSource? localDataSource,
    RiskAssessmentRemoteDataSource? remoteDataSource,
  }) : _localDataSource = localDataSource ?? RiskAssessmentLocalDataSource(),
       _remoteDataSource =
           remoteDataSource ?? RiskAssessmentRemoteDataSource();

  final GetRiskAssessmentQuestionsUseCase _getQuestionsUseCase;
  final RiskAssessmentLocalDataSource _localDataSource;
  final RiskAssessmentRemoteDataSource _remoteDataSource;

  Future<List<RiskQuestionEntity>> loadQuestions() {
    return _getQuestionsUseCase();
  }

  Future<List<RiskQuestionEntity>> loadCachedQuestions() async {
    final cachedPayload = await _localDataSource.getCachedQuestionsPayload();
    if (cachedPayload == null) {
      return const <RiskQuestionEntity>[];
    }

    try {
      return _remoteDataSource.mapPayloadToQuestions(cachedPayload);
    } catch (_) {
      return const <RiskQuestionEntity>[];
    }
  }

  Future<void> submitLatestResult({
    required String riskLevel,
    required String resultLabel,
    required int riskScore,
    required DateTime takenAt,
  }) {
    return _remoteDataSource.submitLatestResult(
      riskLevel: riskLevel,
      resultLabel: resultLabel,
      riskScore: riskScore,
      takenAt: takenAt,
    );
  }
}
