import '../../domain/entities/risk_question_entity.dart';
import '../../domain/repositories/risk_assessment_repository.dart';
import '../datasources/risk_assessment_local_data_source.dart';
import '../datasources/risk_assessment_remote_data_source.dart';

class RiskAssessmentRepositoryImpl implements RiskAssessmentRepository {
  RiskAssessmentRepositoryImpl({
    RiskAssessmentRemoteDataSource? remoteDataSource,
    RiskAssessmentLocalDataSource? localDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? RiskAssessmentRemoteDataSource(),
       _localDataSource = localDataSource ?? RiskAssessmentLocalDataSource();

  final RiskAssessmentRemoteDataSource _remoteDataSource;
  final RiskAssessmentLocalDataSource _localDataSource;

  @override
  Future<List<RiskQuestionEntity>> fetchQuestions() async {
    try {
      final payload = await _remoteDataSource.fetchQuestionsPayload();
      await _localDataSource.cacheQuestionsPayload(payload);
      return _remoteDataSource.mapPayloadToQuestions(payload);
    } catch (e) {
      final cachedPayload = await _localDataSource.getCachedQuestionsPayload();
      if (cachedPayload != null) {
        return _remoteDataSource.mapPayloadToQuestions(cachedPayload);
      }
      throw RiskAssessmentRepositoryException(
        'Failed to load risk assessment questions: $e',
      );
    }
  }
}

class RiskAssessmentRepositoryException implements Exception {
  const RiskAssessmentRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'RiskAssessmentRepositoryException: $message';
}
