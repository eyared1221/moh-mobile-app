import 'risk_option_entity.dart';

class RiskQuestionEntity {
  final String id;
  final int? number;
  final String title;
  final String helper;
  final String type;
  final bool active;
  final List<RiskOptionEntity> options;

  const RiskQuestionEntity({
    required this.id,
    this.number,
    required this.title,
    required this.helper,
    this.type = 'yesno',
    this.active = true,
    required this.options,
  });

  int get maxScore {
    var maxScore = 0;
    for (final option in options) {
      if (option.score > maxScore) {
        maxScore = option.score;
      }
    }
    return maxScore;
  }
}
