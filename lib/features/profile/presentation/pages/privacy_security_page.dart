import 'package:flutter/material.dart';

import 'change_password_page.dart';
import 'privacy_policy_page.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key, this.language, this.email});

  final String? language;
  final String? email;

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: colorScheme.primary,
        title: const Text('Privacy & Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        children: [
          _sectionTitle(context, 'Access Control'),
          const SizedBox(height: 10),
          _settingsSection(
            context,
            children: [
              _settingsTile(
                context,
                icon: Icons.vpn_key_rounded,
                title: 'Change Password',
                subtitle: 'Password • Privacy • Security',
                control: Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.outline,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          _sectionTitle(context, 'Personal Data'),
          const SizedBox(height: 10),
          _settingsSection(
            context,
            children: [
              _settingsTile(
                context,
                icon: Icons.security_rounded,
                title: 'Privacy Policy',
                subtitle: 'Privacy • Terms • Data Use',
                control: Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.outline,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        letterSpacing: 0.4,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _settingsSection(
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

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget control,
    Color? iconColor,
    Color? iconBg,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg ?? colorScheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            control,
          ],
        ),
      ),
    );
  }
}
