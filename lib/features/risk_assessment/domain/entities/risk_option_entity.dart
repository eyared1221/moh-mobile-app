class RiskOptionEntity {
  final String label;
  final int score;

  const RiskOptionEntity({
    required this.label,
    this.score = 0,
  });
}
