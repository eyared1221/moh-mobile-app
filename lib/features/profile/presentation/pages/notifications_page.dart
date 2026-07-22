import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../notifications/data/notification_automation_service.dart';
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
    bool showedSpecificError = false;
    try {
      enabled = await _controller.setPushEnabled(value);
    } catch (error) {
      enabled = false;
      showedSpecificError = true;
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

    if (value && !enabled && !showedSpecificError) {
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
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                _switchSection(
                  context,
                  children: [
                    _switchTile(
                      context,
                      title: 'Push Notifications',
                      value: _pushEnabled,
                      enabled: !_isUpdatingPush,
                      onChanged: _togglePushNotifications,
                    ),
                    _sectionDivider(colorScheme),
                    _switchTile(
                      context,
                      title: 'Welcome Messages',
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
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Account & Safety',
                  style: theme.textTheme.labelLarge?.copyWith(
                    letterSpacing: 0.4,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                _switchSection(
                  context,
                  children: [
                    _switchTile(
                      context,
                      title: 'Account & Security Alerts',
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
              ],
            ),
    );
  }

  Widget _switchSection(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(children: children),
    );
  }

  Widget _sectionDivider(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18),
      child: Divider(
        height: 1,
        thickness: 1,
        color: colorScheme.outlineVariant.withOpacity(0.75),
      ),
    );
  }

  Widget _switchTile(
    BuildContext context, {
    required String title,
    required bool value,
    bool enabled = true,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
SizedBox(
  width: 50,
  height: 30,
  child: FittedBox(
    fit: BoxFit.fill,
    child: Switch(
      value: value,
      onChanged: enabled ? onChanged : null,
      activeColor: Colors.white,
      activeTrackColor: const Color(0xFF005F99),
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.grey.shade400,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
  ),
),
        ],
      ),
    );
  }
}
