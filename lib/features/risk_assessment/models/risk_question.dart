import '../domain/entities/risk_question_entity.dart';
import 'risk_option.dart';

class RiskQuestion extends RiskQuestionEntity {
  const RiskQuestion({
    required super.id,
    super.number,
    required super.title,
    required super.helper,
    super.type = 'yesno',
    super.active = true,
    required List<RiskOption> super.options,
  });
}
