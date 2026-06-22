import 'package:flutter/material.dart';

import '../../../../shared/widgets/ministry_section.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const List<_PolicyItem> _policyItems = [
    _PolicyItem(
      icon: Icons.info_outline_rounded,
      title: 'Overview',
      body: 'We protect your personal and health information securely.',
    ),
    _PolicyItem(
      icon: Icons.folder_copy_outlined,
      title: 'Data We Collect',
      body: 'We may collect profile, contact, and assessment information needed for app services.',
    ),
    _PolicyItem(
      icon: Icons.manage_accounts_outlined,
      title: 'How We Use Data',
      body: 'Your data helps provide guidance, reminders, security, and app improvements.',
      ),
    _PolicyItem(
      icon: Icons.verified_user_outlined,
      title: 'Your Rights',
      body: 'You can access, update, or request deletion of your account data.', 
      ),
    _PolicyItem(
      icon: Icons.lock_outline_rounded,
      title: 'Data Protection & Security',
      body: 'We use secure systems and encryption to protect your information.',
      ),
    _PolicyItem(
      icon: Icons.support_agent_rounded,
      title: 'Contact',
      body: 'Contact us through the Support Center for privacy-related concerns.',
      ),
  ];

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
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        children: [
          const MinistrySection(),


          const SizedBox(height: 30),

          _sectionTitle(context, 'Policy Details'),
          const SizedBox(height: 10),

          _policySection(
            context,
            children: [
              for (int i = 0; i < _policyItems.length; i++) ...[
                _policyTile(
                  context,
                  item: _policyItems[i],
                ),
                if (i != _policyItems.length - 1) _sectionDivider(colorScheme),
              ],
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

  Widget _policySection(
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
      padding: const EdgeInsets.only(left: 76, right: 18),
      child: Divider(
        height: 1,
        thickness: 1,
        color: colorScheme.outlineVariant.withOpacity(0.75),
      ),
    );
  }

  Widget _policyTile(
    BuildContext context, {
    required _PolicyItem item,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: colorScheme.primary,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  item.body,
                  textAlign: TextAlign.left,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyItem {
  const _PolicyItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}