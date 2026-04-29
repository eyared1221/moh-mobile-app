import '../domain/entities/risk_option_entity.dart';

class RiskOption extends RiskOptionEntity {
  const RiskOption({
    required super.label,
    super.score = 0,
  });
}
