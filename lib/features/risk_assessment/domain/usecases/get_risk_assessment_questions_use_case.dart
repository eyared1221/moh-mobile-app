import '../entities/risk_question_entity.dart';
import '../repositories/risk_assessment_repository.dart';

class GetRiskAssessmentQuestionsUseCase {
  const GetRiskAssessmentQuestionsUseCase(this._repository);

  final RiskAssessmentRepository _repository;

  Future<List<RiskQuestionEntity>> call() {
    return _repository.fetchQuestions();
  }
}
