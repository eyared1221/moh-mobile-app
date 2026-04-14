import 'package:flutter/material.dart';

import '../../../../shared/widgets/ministry_section.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: colorScheme.primary,
        title: const Text('Privacy Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
        children: [
          const MinistrySection(),
          const SizedBox(height: 12),
          _section(
            context,
            title: 'Overview',
            body:
                'Yegna Health protects your privacy and handles your personal '
                'and health information securely. This policy explains what '
                'we collect, how we use it, and your rights.',
          ),
          _section(
            context,
            title: 'Data We Collect',
            body:
                'We may collect the following types of information:\n\n'
                '• Personal Information: such as name, phone number, or email '
                '(if provided)\n'
                '• Profile Information: such as age group, preferences, and settings\n'
                '• Health Assessment Data: responses from risk assessments '
                '(e.g., HIV, STI, or wellbeing questionnaires)\n'
                '• Usage Data: how you interact with the app to improve performance '
                'and services\n\n'
                'We do NOT collect unnecessary personal data beyond what is '
                'required for providing health services.',
          ),
          _section(
            context,
            title: 'How We Use Data',
            body:
                'Your data is used to:\n\n'
                '• Provide personalized health guidance and recommendations\n'
                '• Improve the quality and accuracy of health information\n'
                '• Send reminders (e.g., risk assessments, learning modules)\n'
                '• Ensure account security and prevent misuse\n'
                '• Support public health insights in an anonymized and aggregated '
                'manner\n\n'
                'We do NOT sell or share your personal data for commercial purposes.',
          ),
          _section(
            context,
            title: 'Your Rights',
            body:
                'You have the right to:\n\n'
                '• Access your personal data\n'
                '• Request correction of inaccurate information\n'
                '• Request deletion of your account and associated data\n'
                '• Control notification and privacy preferences within the app\n\n'
                'Requests can be made through the app settings or support channels.',
          ),
          _section(
            context,
            title: 'Data Protection & Security',
            body:
                'We use industry-standard security measures to protect your data, '
                'including encryption and secure authentication systems.\n\n'
                'Only authorized systems and personnel can access your data. '
                'We continuously monitor and improve our security practices to '
                'ensure your information remains safe.',
          ),
          _section(
            context,
            title: 'Contact',
            body:
                'If you have questions or concerns about your privacy, please '
                'contact us through the Support Center in the app or the Ministry '
                'of Health official communication channels.',
          ),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.justify,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
