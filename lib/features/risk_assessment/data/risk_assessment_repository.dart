import '../domain/entities/risk_question_entity.dart';
import 'datasources/risk_assessment_local_data_source.dart';
import 'datasources/risk_assessment_remote_data_source.dart';
import 'repositories/risk_assessment_repository_impl.dart';

class RiskAssessmentRepository extends RiskAssessmentRepositoryImpl {
  RiskAssessmentRepository({
    super.remoteDataSource,
    super.localDataSource,
  });

  @override
  Future<List<RiskQuestionEntity>> fetchQuestions() {
    return super.fetchQuestions();
  }
}
