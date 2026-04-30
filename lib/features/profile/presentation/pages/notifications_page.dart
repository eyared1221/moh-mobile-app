import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../notifications/data/notification_automation_service.dart';
import '../../domain/entities/notification_preferences_entity.dart';
import '../controllers/profile_controller.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ProfileController _controller = ProfileController.standard();
  final NotificationAutomationService _automationService =
      NotificationAutomationService.instance;

  bool _isLoading = true;
  bool _isUpdatingPush = false;
  bool _pushEnabled = true;
  bool _welcome = true;
  bool _inactivity = true;
  bool _riskAssessment = true;
  bool _learning = true;
  bool _security = true;

  bool get _pushSupported => _controller.isPushSupported;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await _controller.loadNotificationPreferences();
    if (!mounted) return;
    setState(() {
      _pushEnabled = _pushSupported && prefs.pushEnabled;
      _welcome = prefs.welcome;
      _inactivity = prefs.inactivity;
      _riskAssessment = prefs.riskAssessment;
      _learning = prefs.learning;
      _security = prefs.security;
      _isLoading = false;
    });
  }

  Future<void> _save(String key, bool value) async {
    await _controller.setNotificationPreference(key, value);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _unsupportedPushMessage() {
    if (kIsWeb) {
      return 'Push notifications are not available in the browser version yet. Use the Android or iPhone app.';
    }

    return 'Push notifications are only available on Android and iPhone.';
  }

  Future<void> _togglePushNotifications(bool value) async {
    if (!_pushSupported) {
      await _controller.setNotificationPreference(_controller.notifyPushKey, false);
      if (!mounted) return;
      setState(() => _pushEnabled = false);
      _showMessage(_unsupportedPushMessage());
      return;
    }

    setState(() => _isUpdatingPush = true);

    bool enabled = false;
    try {
      enabled = await _controller.setPushEnabled(value);
    } catch (error) {
      enabled = false;
      await _controller.setNotificationPreference(_controller.notifyPushKey, false);
      if (mounted) {
        _showMessage(error.toString().replaceFirst('Exception: ', ''));
      }
    }

    if (!mounted) return;
    setState(() {
      _pushEnabled = enabled;
      _isUpdatingPush = false;
    });

    if (value && !enabled) {
      _showMessage(
        'Push notifications are still off. Allow notification permission and confirm Firebase is configured for this device.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Notifications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              children: [
                Text(
                  'General',
                  style: theme.textTheme.labelLarge?.copyWith(
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                _switchTile(
                  context,
                  title: 'Push Notifications',
                  subtitle: _pushSupported
                      ? 'Receive reminders and updates even when the app is closed'
                      : 'Available in the Android or iPhone app. The browser version does not support this yet.',
                  value: _pushEnabled,
                  enabled: !_isUpdatingPush,
                  onChanged: _togglePushNotifications,
                ),
                const SizedBox(height: 12),
                _switchTile(
                  context,
                  title: 'Welcome Messages',
                  subtitle: 'Show an automatic welcome message after sign-in',
                  value: _welcome,
                  onChanged: (value) async {
                    setState(() => _welcome = value);
                    await _save(_controller.notifyWelcomeKey, value);
                    await _automationService.handleNotificationPreferenceChanged(
                      _controller.notifyWelcomeKey,
                      value,
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Learning & Guidance',
                  style: theme.textTheme.labelLarge?.copyWith(
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                _switchTile(
                  context,
                  title: 'Last Login Reminders',
                  subtitle: 'Get an automatic reminder after a period of inactivity',
                  value: _inactivity,
                  onChanged: (value) async {
                    setState(() => _inactivity = value);
                    await _save(_controller.notifyInactivityKey, value);
                    await _automationService.handleNotificationPreferenceChanged(
                      _controller.notifyInactivityKey,
                      value,
                    );
                  },
                ),
                const SizedBox(height: 12),
                _switchTile(
                  context,
                  title: 'Risk Assessment Reminders',
                  subtitle: 'Get helpful reminders to assess regularly',
                  value: _riskAssessment,
                  onChanged: (value) async {
                    setState(() => _riskAssessment = value);
                    await _save(_controller.notifyRiskAssessmentKey, value);
                    await _automationService.handleNotificationPreferenceChanged(
                      _controller.notifyRiskAssessmentKey,
                      value,
                    );
                  },
                ),
                const SizedBox(height: 12),
                _switchTile(
                  context,
                  title: 'Learning Module Updates',
                  subtitle: 'Know when new health lessons and learning content are available',
                  value: _learning,
                  onChanged: (value) async {
                    setState(() => _learning = value);
                    await _save(_controller.notifyLearningKey, value);
                    await _automationService.handleNotificationPreferenceChanged(
                      _controller.notifyLearningKey,
                      value,
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Account & Safety',
                  style: theme.textTheme.labelLarge?.copyWith(
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                _switchTile(
                  context,
                  title: 'Account & Security Alerts',
                  subtitle: 'Stay informed about sign-in activity and important account changes',
                  value: _security,
                  onChanged: (value) async {
                    setState(() => _security = value);
                    await _save(_controller.notifySecurityKey, value);
                    await _automationService.handleNotificationPreferenceChanged(
                      _controller.notifySecurityKey,
                      value,
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _switchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    bool enabled = true,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch.adaptive(
            value: value,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}
