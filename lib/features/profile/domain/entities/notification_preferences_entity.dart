class NotificationPreferencesEntity {
  final bool pushEnabled;
  final bool welcome;
  final bool sound;
  final bool inactivity;
  final bool riskAssessment;
  final bool learning;
  final bool security;

  const NotificationPreferencesEntity({
    required this.pushEnabled,
    required this.welcome,
    required this.sound,
    required this.inactivity,
    required this.riskAssessment,
    required this.learning,
    required this.security,
  });
}
