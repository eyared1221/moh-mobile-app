import '../../domain/entities/risk_question_entity.dart';
import '../../domain/usecases/get_risk_assessment_questions_use_case.dart';

class RiskAssessmentPageController {
  const RiskAssessmentPageController(this._getQuestionsUseCase);

  final GetRiskAssessmentQuestionsUseCase _getQuestionsUseCase;

  Future<List<RiskQuestionEntity>> loadQuestions() {
    return _getQuestionsUseCase();
  }
}
