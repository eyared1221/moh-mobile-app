import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_container.dart';
import '../../domain/entities/profile_user_entity.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({
    super.key,
    required this.profile,
  });

  final ProfileUserEntity profile;

  String get _primaryContact {
    final phone = profile.phone.trim();
    if (phone.isNotEmpty) {
      return phone;
    }

    final email = profile.email.trim();
    if (email.isNotEmpty) {
      return email;
    }

    return 'Not available';
  }

  String get _primaryContactLabel {
    if (profile.phone.trim().isNotEmpty) {
      return 'Phone Number';
    }

    if (profile.email.trim().isNotEmpty) {
      return 'Email Address';
    }

    return 'Contact Details';
  }

  IconData get _primaryContactIcon {
    if (profile.phone.trim().isNotEmpty) {
      return Icons.call_rounded;
    }

    return Icons.alternate_email_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final pageBackground =
        isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF4F5F8);

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.primary,
        centerTitle: true,
        title: Text(
          'Account',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : colorScheme.primary,
          ),
        ),
      ),
      body: ResponsiveContainer.safe(
        child: ResponsiveContainer.scrollable(
          context: context,
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'View the personal information associated with your Wise Youth account. Your details are used to personalize your experience and provide relevant health resources.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              _SectionCard(
                title: 'Your Info',
                accent: colorScheme.primary,
                child: Column(
                  children: [
                    _InfoRow(
                      icon: _primaryContactIcon,
                      title: _primaryContact,
                      subtitle: _primaryContactLabel,
                    ),
                    _CardDivider(color: colorScheme.outlineVariant),
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      title: profile.fullName.trim().isEmpty
                          ? 'Yegna User'
                          : profile.fullName.trim(),
                      subtitle: 'Profile Name',
                    ),
                    _CardDivider(color: colorScheme.outlineVariant),
                    _InfoRow(
                      icon: Icons.cake_outlined,
                      title: '${profile.age}',
                      subtitle: 'Age',
                    ),
                    _CardDivider(color: colorScheme.outlineVariant),
                    _InfoRow(
                      icon: Icons.language_rounded,
                      title: profile.language.trim().isEmpty
                          ? 'English'
                          : profile.language.trim(),
                      subtitle: 'Language Preference',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Your personal information is securely stored and used only to provide a personalized experience within Wise Youth.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    this.title,
    this.accent,
  });

  final Widget child;
  final String? title;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: accent ?? colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: color.withOpacity(0.7),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ) ??
                      TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13.5,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ) ??
                      TextStyle(
                        fontSize: 13.5,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
