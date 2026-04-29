import '../entities/risk_question_entity.dart';

abstract class RiskAssessmentRepository {
  Future<List<RiskQuestionEntity>> fetchQuestions();
}
