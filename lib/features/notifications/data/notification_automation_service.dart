import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../profile/data/datasources/profile_local_data_source.dart';
import '../models/app_notification.dart';
import 'app_notification_service.dart';

class NotificationAutomationService {
  NotificationAutomationService({
    AppNotificationService? notificationService,
    ProfileLocalDataSource? profileLocalDataSource,
  }) : _notificationService =
           notificationService ?? AppNotificationService.instance,
       _profileLocalDataSource =
           profileLocalDataSource ?? ProfileLocalDataSource();

  static final NotificationAutomationService instance =
      NotificationAutomationService();

  static const Duration inactivityReminderDelay = Duration(days: 3);
  static const Duration riskAssessmentReminderDelay = Duration(days: 7);

  static const String _migrationKey = 'notifications_live_behavior_v2';
  static const String _lastActiveAtKey = 'notifications_last_active_at';
  static const String _lastSignInAtKey = 'notifications_last_sign_in_at';
  static const String _lastRiskAssessmentAtKey =
      'notifications_last_risk_assessment_at';
  static const String _riskReminderStartAtKey =
      'notifications_risk_reminder_start_at';
  static const String _lastRiskReminderAtKey =
      'notifications_last_risk_reminder_at';
  static const String _lastInactivityReminderSourceKey =
      'notifications_last_inactivity_reminder_source';
  static const String _learningSignatureKey = 'notifications_learning_signature';

  static const Set<String> _legacySeededNotificationIds = {
    'welcome-message',
    'risk-assessment-reminder',
    'learning-update',
    'security-alert',
    'inactivity-reminder',
  };

  final AppNotificationService _notificationService;
  final ProfileLocalDataSource _profileLocalDataSource;

  Future<void> initialize() async {
    await _migrateLegacySeededNotifications();
    await refreshAutomatedNotifications(markAppActive: true);
  }

  Future<void> handleAppForegrounded() {
    return refreshAutomatedNotifications(markAppActive: true);
  }

  Future<void> handleManualSync() {
    return refreshAutomatedNotifications(markAppActive: true);
  }

  Future<void> handleSuccessfulSignIn({
    required String userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final nowIso = now.toIso8601String();

    await prefs.setString(_lastSignInAtKey, nowIso);
    await prefs.setString(_lastActiveAtKey, nowIso);
    await prefs.setString(
      _riskReminderStartAtKey,
      prefs.getString(_riskReminderStartAtKey) ?? nowIso,
    );

    await _migrateLegacySeededNotifications();
    await _reconcileNotificationPreferences();

    await _notificationService.addNotification(
      AppNotification(
        id: 'welcome-${now.millisecondsSinceEpoch}',
        type: 'welcome',
        title: 'Welcome back',
        message: 'Welcome back, $userName. Your health dashboard is ready.',
        createdAt: now,
      ),
    );
  }

  Future<void> handleLearningModulesPayload(
    Map<String, dynamic> payload,
  ) async {
    if (!await _isLoggedIn()) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final previousSignature = prefs.getString(_learningSignatureKey);
    final currentSignature = _buildLearningSignature(payload);

    await prefs.setString(_learningSignatureKey, currentSignature);

    if (previousSignature == null || previousSignature == currentSignature) {
      return;
    }

    final previousIds = _extractLearningModuleIds(previousSignature);
    final currentIds = _extractLearningModuleIds(currentSignature);
    final newModuleCount = currentIds.difference(previousIds).length;
    final now = DateTime.now();

    await _notificationService.addNotification(
      AppNotification(
        id: 'learning-${currentSignature.hashCode}',
        type: 'learning',
        title: 'Learning modules updated',
        message: newModuleCount > 0
            ? '$newModuleCount new learning module${newModuleCount == 1 ? '' : 's'} are available now.'
            : 'Learning content has been updated. Open Learning Modules to see what changed.',
        createdAt: now,
      ),
    );
  }

  Future<void> recordRiskAssessmentCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final nowIso = DateTime.now().toIso8601String();

    await prefs.setString(_lastRiskAssessmentAtKey, nowIso);
    await prefs.setString(_riskReminderStartAtKey, nowIso);
    await prefs.remove(_lastRiskReminderAtKey);
    await _notificationService.deleteNotificationsByTypes({
      'risk_assessment',
    });
  }

  Future<void> handleNotificationPreferenceChanged(
    String key,
    bool enabled,
  ) async {
    if (!enabled) {
      final types = _notificationTypesForPreferenceKey(key);
      if (types.isNotEmpty) {
        await _notificationService.deleteNotificationsByTypes(types);
      }
      return;
    }

    await refreshAutomatedNotifications(markAppActive: false);
  }

  Future<void> refreshAutomatedNotifications({
    required bool markAppActive,
  }) async {
    if (!await _isLoggedIn()) {
      return;
    }

    await _migrateLegacySeededNotifications();
    await _reconcileNotificationPreferences();

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastActiveAt = _parseDateTime(prefs.getString(_lastActiveAtKey));

    await _maybeCreateInactivityReminder(
      prefs: prefs,
      now: now,
      lastActiveAt: lastActiveAt,
    );
    await _maybeCreateRiskAssessmentReminder(
      prefs: prefs,
      now: now,
    );

    if (markAppActive) {
      await prefs.setString(_lastActiveAtKey, now.toIso8601String());
    }
  }

  Future<void> _maybeCreateInactivityReminder({
    required SharedPreferences prefs,
    required DateTime now,
    required DateTime? lastActiveAt,
  }) async {
    if (lastActiveAt == null) {
      return;
    }

    if (now.difference(lastActiveAt) < inactivityReminderDelay) {
      return;
    }

    final reminderSource = prefs.getString(_lastInactivityReminderSourceKey);
    final currentSource = lastActiveAt.toIso8601String();
    if (reminderSource == currentSource) {
      return;
    }

    await _notificationService.addNotification(
      AppNotification(
        id: 'inactivity-${lastActiveAt.millisecondsSinceEpoch}',
        type: 'reminder',
        title: 'It has been a while',
        message:
            'You have been away for a bit. Come back for a quick health check-in.',
        createdAt: now,
      ),
    );
    await prefs.setString(_lastInactivityReminderSourceKey, currentSource);
  }

  Future<void> _maybeCreateRiskAssessmentReminder({
    required SharedPreferences prefs,
    required DateTime now,
  }) async {
    final lastAssessmentAt = _parseDateTime(
      prefs.getString(_lastRiskAssessmentAtKey),
    );
    final lastRiskReminderAt = _parseDateTime(
      prefs.getString(_lastRiskReminderAtKey),
    );
    final riskReminderStartAt = _parseDateTime(
      prefs.getString(_riskReminderStartAtKey),
    );

    final baseline = lastAssessmentAt ?? riskReminderStartAt;
    if (baseline == null) {
      return;
    }

    final comparisonPoint = lastRiskReminderAt != null &&
            lastRiskReminderAt.isAfter(baseline)
        ? lastRiskReminderAt
        : baseline;
    if (now.difference(comparisonPoint) < riskAssessmentReminderDelay) {
      return;
    }

    await _notificationService.addNotification(
      AppNotification(
        id: 'risk-${comparisonPoint.millisecondsSinceEpoch}',
        type: 'risk_assessment',
        title: 'Risk assessment reminder',
        message:
            'It is time for another quick risk assessment to keep your guidance up to date.',
        createdAt: now,
      ),
    );
    await prefs.setString(_lastRiskReminderAtKey, now.toIso8601String());
  }

  Future<void> _reconcileNotificationPreferences() async {
    final notificationPrefs =
        await _profileLocalDataSource.getNotificationPreferences();
    final disabledTypes = <String>{};

    if (!notificationPrefs.welcome) {
      disabledTypes.add('welcome');
    }
    if (!notificationPrefs.riskAssessment) {
      disabledTypes.add('risk_assessment');
    }
    if (!notificationPrefs.learning) {
      disabledTypes.add('learning');
    }
    if (!notificationPrefs.security) {
      disabledTypes.add('security');
    }
    if (!notificationPrefs.inactivity) {
      disabledTypes.add('reminder');
    }

    if (disabledTypes.isNotEmpty) {
      await _notificationService.deleteNotificationsByTypes(disabledTypes);
    }
  }

  Future<void> _migrateLegacySeededNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationKey) ?? false) {
      return;
    }

    await _notificationService.deleteNotificationsByIds(
      _legacySeededNotificationIds,
    );
    await prefs.setBool(_migrationKey, true);
  }

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  String _buildLearningSignature(Map<String, dynamic> payload) {
    final modules = payload['data'] as List<dynamic>? ?? const <dynamic>[];
    final normalized = modules
        .whereType<Map<String, dynamic>>()
        .map(_normalizeLearningModuleForSignature)
        .toList()
      ..sort((a, b) => '${a['slug']}'.compareTo('${b['slug']}'));
    return jsonEncode(normalized);
  }

  Map<String, dynamic> _normalizeLearningModuleForSignature(
    Map<String, dynamic> module,
  ) {
    final normalized = <String, dynamic>{};
    final sortedKeys = module.keys.toList()..sort();

    for (final key in sortedKeys) {
      normalized[key] = _normalizeSignatureValue(module[key]);
    }

    return normalized;
  }

  dynamic _normalizeSignatureValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      final normalized = <String, dynamic>{};
      final sortedKeys = value.keys.toList()..sort();
      for (final key in sortedKeys) {
        normalized[key] = _normalizeSignatureValue(value[key]);
      }
      return normalized;
    }

    if (value is Map) {
      final normalized = <String, dynamic>{};
      final sortedKeys = value.keys.map((key) => '$key').toList()..sort();
      for (final key in sortedKeys) {
        normalized[key] = _normalizeSignatureValue(value[key]);
      }
      return normalized;
    }

    if (value is List) {
      final normalizedList =
          value.map((item) => _normalizeSignatureValue(item)).toList();
      if (_shouldSortSignatureList(normalizedList)) {
        normalizedList.sort(
          (a, b) => jsonEncode(a).compareTo(jsonEncode(b)),
        );
      }
      return normalizedList;
    }

    return value;
  }

  bool _shouldSortSignatureList(List<dynamic> items) {
    return items.isNotEmpty &&
        items.every((item) => item is Map || item is Map<String, dynamic>);
  }

  Set<String> _extractLearningModuleIds(String signature) {
    try {
      final decoded = jsonDecode(signature);
      if (decoded is! List) {
        return <String>{};
      }

      return decoded
          .whereType<Map>()
          .map((item) => item['slug']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Set<String> _notificationTypesForPreferenceKey(String key) {
    if (key == ProfileLocalDataSource.notifyWelcomeKey) {
      return {'welcome'};
    }
    if (key == ProfileLocalDataSource.notifyRiskAssessmentKey) {
      return {'risk_assessment'};
    }
    if (key == ProfileLocalDataSource.notifyLearningKey) {
      return {'learning'};
    }
    if (key == ProfileLocalDataSource.notifySecurityKey) {
      return {'security'};
    }
    if (key == ProfileLocalDataSource.notifyInactivityKey) {
      return {'reminder'};
    }
    return const <String>{};
  }

  DateTime? _parseDateTime(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}
