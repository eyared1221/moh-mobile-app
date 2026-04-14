import 'package:flutter/material.dart';

import '../../data/profile_repository.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ProfileRepository _repository = ProfileRepository();
  bool _isLoading = true;
  bool _welcome = true;
  bool _inactivity = true;
  bool _riskAssessment = true;
  bool _learning = true;
  bool _security = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await _repository.fetchNotificationPrefs();
    if (!mounted) return;
    setState(() {
      _welcome = prefs[_repository.notifyWelcomeKey] ?? true;
      _inactivity = prefs[_repository.notifyInactivityKey] ?? true;
      _riskAssessment = prefs[_repository.notifyRiskAssessmentKey] ?? true;
      _learning = prefs[_repository.notifyLearningKey] ?? true;
      _security = prefs[_repository.notifySecurityKey] ?? true;
      _isLoading = false;
    });
  }

  Future<void> _save(String key, bool value) async {
    await _repository.setNotificationPref(key, value);
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
                  title: 'Welcome Messages',
                  subtitle: 'Show an automatic welcome message after sign-in',
                  value: _welcome,
                  onChanged: (value) {
                    setState(() => _welcome = value);
                    _save(_repository.notifyWelcomeKey, value);
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
                  onChanged: (value) {
                    setState(() => _inactivity = value);
                    _save(_repository.notifyInactivityKey, value);
                  },
                ),
                const SizedBox(height: 12),
                _switchTile(
                  context,
                  title: 'Risk Assessment Reminders',
                  subtitle: 'Get helpful reminders to assess regularly',
                  value: _riskAssessment,
                  onChanged: (value) {
                    setState(() => _riskAssessment = value);
                    _save(_repository.notifyRiskAssessmentKey, value);
                  },
                ),
                const SizedBox(height: 12),
                _switchTile(
                  context,
                  title: 'Learning Module Updates',
                  subtitle: 'Know when new health lessons and learning content are available',
                  value: _learning,
                  onChanged: (value) {
                    setState(() => _learning = value);
                    _save(_repository.notifyLearningKey, value);
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
                  onChanged: (value) {
                    setState(() => _security = value);
                    _save(_repository.notifySecurityKey, value);
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
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
