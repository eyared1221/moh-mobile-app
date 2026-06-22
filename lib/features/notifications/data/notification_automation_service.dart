import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../profile/data/datasources/profile_local_data_source.dart';
import '../models/app_notification.dart';
import 'app_notification_service.dart';
import 'push_notification_service.dart';

class NotificationAutomationService {
  NotificationAutomationService({
    AppNotificationService? notificationService,
    ProfileLocalDataSource? profileLocalDataSource,
    PushNotificationService? pushNotificationService,
  }) : _notificationService =
           notificationService ?? AppNotificationService.instance,
       _profileLocalDataSource =
           profileLocalDataSource ?? ProfileLocalDataSource(),
       _pushNotificationService =
           pushNotificationService ?? PushNotificationService.instance;

  static final NotificationAutomationService instance =
      NotificationAutomationService();

  static const Duration inactivityReminderDelay = Duration(days: 3);

  static const String _migrationKey = 'notifications_live_behavior_v2';
  static const String _lastActiveAtKey = 'notifications_last_active_at';
  static const String _lastSignInAtKey = 'notifications_last_sign_in_at';
  static const String _lastRiskAssessmentAtKey =
      'notifications_last_risk_assessment_at';
  static const String _riskReminderStartAtKey =
      'notifications_risk_reminder_start_at';
  static const String _lastInactivityReminderSourceKey =
      'notifications_last_inactivity_reminder_source';
  static const String _learningSignatureKey = 'notifications_learning_signature';
  static const String _riskLevelKey = 'notifications_risk_level';
  static const String _learningModulesDataKey = 'notifications_learning_modules_data';

  static const Set<String> _legacySeededNotificationIds = {
    'welcome-message',
    'risk-assessment-reminder',
    'learning-update',
    'security-alert',
    'inactivity-reminder',
  };

  static const List<_RiskReminderTemplate> _riskReminderTemplates = [
    _RiskReminderTemplate(
      dayOffset: 7,
      title: 'Health Check-In',
      message:
          'It has been 7 days since your HIV assessment. Review your results anytime.',
    ),
    _RiskReminderTemplate(
      dayOffset: 14,
      title: 'Stay Informed',
      message:
          'It has been 14 days since your HIV assessment. Take a quick reassessment if needed.',
    ),
    _RiskReminderTemplate(
      dayOffset: 30,
      title: 'Time to Reassess',
      message:
          'It has been 30 days since your HIV assessment. Retake it for updated guidance.',
    ),
  ];

  final AppNotificationService _notificationService;
  final ProfileLocalDataSource _profileLocalDataSource;
  final PushNotificationService _pushNotificationService;

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

    await _addAutomatedNotification(
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

    final notificationPrefs =
        await _profileLocalDataSource.getNotificationPreferences();
    if (!notificationPrefs.learning) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final previousData = prefs.getString(_learningModulesDataKey);
    final currentData = jsonEncode(payload);

    await prefs.setString(_learningModulesDataKey, currentData);

    if (previousData == null || previousData == currentData) {
      return;
    }

    final previousModules = _parseLearningModules(previousData);
    final currentModules = _parseLearningModules(currentData);

    final changeType = _detectLearningChangeType(
      previousModules,
      currentModules,
    );

    if (changeType == null) {
      return;
    }

    final now = DateTime.now();
    String title;
    String message;

    switch (changeType) {
      case _LearningChangeType.newModule:
        title = 'New Learning Module';
        message = 'New health learning content is available for you.';
        break;
      case _LearningChangeType.updatedModule:
        title = 'Learning Content Updated';
        message = 'One of your health lessons has been updated.';
        break;
      case _LearningChangeType.newHIVContent:
        title = 'New HIV Learning Content';
        message = 'New HIV prevention resources are available.';
        break;
    }

    await _addAutomatedNotification(
      AppNotification(
        id: 'learning-${now.millisecondsSinceEpoch}',
        type: 'learning',
        title: title,
        message: message,
        createdAt: now,
      ),
    );
  }

  Future<void> recordRiskAssessmentCompleted({required String riskLevel}) async {
    final prefs = await SharedPreferences.getInstance();
    final previousBaseline = _riskReminderBaselineFromPrefs(prefs);
    final now = DateTime.now();
    final nowIso = now.toIso8601String();

    await _cancelRiskAssessmentSchedulesForBaseline(previousBaseline);

    await prefs.setString(_lastRiskAssessmentAtKey, nowIso);
    await prefs.setString(_riskReminderStartAtKey, nowIso);
    await prefs.setString(_riskLevelKey, riskLevel);
    await _notificationService.deleteNotificationsByTypes({
      'risk_assessment',
    });
    await _syncRiskAssessmentReminderNotifications(
      prefs: prefs,
      now: now,
    );
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
      if (types.contains('risk_assessment')) {
        final prefs = await SharedPreferences.getInstance();
        await _cancelRiskAssessmentSchedulesForBaseline(
          _riskReminderBaselineFromPrefs(prefs),
        );
      }
      return;
    }

    await refreshAutomatedNotifications(markAppActive: false);
  }

  Future<void> notifyPasswordChanged() async {
    if (!await _isLoggedIn()) {
      return;
    }

    final notificationPrefs =
        await _profileLocalDataSource.getNotificationPreferences();
    if (!notificationPrefs.security) {
      return;
    }

    final now = DateTime.now();
    await _addAutomatedNotification(
      AppNotification(
        id: 'security-password-${now.millisecondsSinceEpoch}',
        type: 'security',
        title: 'Password Updated',
        message: 'Your account password was changed successfully.',
        createdAt: now,
      ),
    );
  }

  Future<void> notifyAccountDetailsUpdated() async {
    if (!await _isLoggedIn()) {
      return;
    }

    final notificationPrefs =
        await _profileLocalDataSource.getNotificationPreferences();
    if (!notificationPrefs.security) {
      return;
    }

    final now = DateTime.now();
    await _addAutomatedNotification(
      AppNotification(
        id: 'security-account-${now.millisecondsSinceEpoch}',
        type: 'security',
        title: 'Account Details Updated',
        message: 'Your account contact information was updated.',
        createdAt: now,
      ),
    );
  }

  Future<void> refreshAutomatedNotifications({
    required bool markAppActive,
  }) async {
    if (!await _isLoggedIn()) {
      final prefs = await SharedPreferences.getInstance();
      await _cancelRiskAssessmentSchedulesForBaseline(
        _riskReminderBaselineFromPrefs(prefs),
      );
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
    await _syncRiskAssessmentReminderNotifications(
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

    await _addAutomatedNotification(
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

  Future<void> _syncRiskAssessmentReminderNotifications({
    required SharedPreferences prefs,
    required DateTime now,
  }) async {
    final baseline = _riskReminderBaselineFromPrefs(prefs);
    if (baseline == null) {
      return;
    }

    final notificationPrefs =
        await _profileLocalDataSource.getNotificationPreferences();
    if (!notificationPrefs.riskAssessment) {
      await _cancelRiskAssessmentSchedulesForBaseline(baseline);
      return;
    }

    final reminders = _buildRiskAssessmentReminders(baseline);
    for (final reminder in reminders) {
      if (reminder.scheduledAt.isAfter(now)) {
        await _pushNotificationService.scheduleLocalAppNotification(
          reminder.notification,
          scheduledAt: reminder.scheduledAt,
        );
        continue;
      }

      await _notificationService.addNotificationIfNew(reminder.notification);
    }
  }

  Future<void> _cancelRiskAssessmentSchedulesForBaseline(
    DateTime? baseline,
  ) async {
    if (baseline == null) {
      return;
    }

    final reminders = _buildRiskAssessmentReminders(baseline);
    for (final reminder in reminders) {
      await _pushNotificationService.cancelLocalAppNotification(
        reminder.notification.id,
      );
    }
  }

  Future<void> _addAutomatedNotification(AppNotification notification) async {
    final storedNotification = await _notificationService.addNotificationIfNew(
      notification,
    );
    if (storedNotification == null) {
      return;
    }

    await _pushNotificationService.showLocalAppNotification(storedNotification);
  }

  DateTime? _riskReminderBaselineFromPrefs(SharedPreferences prefs) {
    return _parseDateTime(prefs.getString(_lastRiskAssessmentAtKey)) ??
        _parseDateTime(prefs.getString(_riskReminderStartAtKey));
  }

  List<_ScheduledRiskReminder> _buildRiskAssessmentReminders(
    DateTime baseline,
  ) {
    return _riskReminderTemplates.map((template) {
      final scheduledAt = baseline.add(Duration(days: template.dayOffset));
      return _ScheduledRiskReminder(
        scheduledAt: scheduledAt,
        notification: AppNotification(
          id: 'risk-${baseline.millisecondsSinceEpoch}-day-${template.dayOffset}',
          type: 'risk_assessment',
          title: template.title,
          message: template.message,
          createdAt: scheduledAt,
        ),
      );
    }).toList();
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

  List<Map<String, dynamic>> _parseLearningModules(String jsonData) {
    try {
      final decoded = jsonDecode(jsonData);
      if (decoded is! Map<String, dynamic>) {
        return const [];
      }

      final data = decoded['data'];
      if (data is! List) {
        return const [];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  _LearningChangeType? _detectLearningChangeType(
    List<Map<String, dynamic>> previousModules,
    List<Map<String, dynamic>> currentModules,
  ) {
    final previousSlugs = previousModules
        .map((m) => m['slug']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet();

    final currentSlugs = currentModules
        .map((m) => m['slug']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet();

    final newSlugs = currentSlugs.difference(previousSlugs);
    final commonSlugs = currentSlugs.intersection(previousSlugs);

    if (newSlugs.isNotEmpty) {
      final hasHIVContent = newSlugs.any((slug) =>
          slug.toLowerCase().contains('hiv') ||
          previousModules.any((m) => m['slug'] == slug &&
              (m['title']?.toString().toLowerCase().contains('hiv') ?? false)));

      return hasHIVContent
          ? _LearningChangeType.newHIVContent
          : _LearningChangeType.newModule;
    }

    for (final slug in commonSlugs) {
      final previousModule = previousModules.firstWhere(
        (m) => m['slug'] == slug,
        orElse: () => <String, dynamic>{},
      );
      final currentModule = currentModules.firstWhere(
        (m) => m['slug'] == slug,
        orElse: () => <String, dynamic>{},
      );

      final previousSections = previousModule['sections'] as List? ?? [];
      final currentSections = currentModule['sections'] as List? ?? [];

      if (previousSections.length != currentSections.length) {
        return _LearningChangeType.updatedModule;
      }

      final previousUpdatedAt = previousModule['updatedAt']?.toString();
      final currentUpdatedAt = currentModule['updatedAt']?.toString();

      if (previousUpdatedAt != null &&
          currentUpdatedAt != null &&
          previousUpdatedAt != currentUpdatedAt) {
        return _LearningChangeType.updatedModule;
      }

      for (final section in currentSections) {
        if (section is! Map<String, dynamic>) continue;
        final previousSection = previousSections.firstWhere(
          (s) => s is Map && s['id'] == section['id'],
          orElse: () => null,
        );

        if (previousSection == null) {
          return _LearningChangeType.updatedModule;
        }

        final previousBlocks = previousSection['blocks'] as List? ?? [];
        final currentBlocks = section['blocks'] as List? ?? [];

        if (previousBlocks.length != currentBlocks.length) {
          return _LearningChangeType.updatedModule;
        }
      }
    }

    return null;
  }
}

enum _LearningChangeType {
  newModule,
  updatedModule,
  newHIVContent,
}

class _RiskReminderTemplate {
  final int dayOffset;
  final String title;
  final String message;

  const _RiskReminderTemplate({
    required this.dayOffset,
    required this.title,
    required this.message,
  });
}

class _ScheduledRiskReminder {
  final DateTime scheduledAt;
  final AppNotification notification;

  const _ScheduledRiskReminder({
    required this.scheduledAt,
    required this.notification,
  });
}
