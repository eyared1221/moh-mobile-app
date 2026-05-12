import 'package:flutter/material.dart';

import '../../../../core/theme/theme_notifier.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Theme'),
      ),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, mode, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(
                'Appearance',
                style: theme.textTheme.labelLarge?.copyWith(
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              _optionTile(
                context,
                title: 'Light',
                subtitle: 'Always use the light appearance',
                value: ThemeMode.light,
                groupValue: mode,
              ),
              const SizedBox(height: 12),
              _optionTile(
                context,
                title: 'Dark',
                subtitle: 'Always use the dark appearance',
                value: ThemeMode.dark,
                groupValue: mode,
              ),
              const SizedBox(height: 12),
              _optionTile(
                context,
                title: 'Use system default',
                subtitle: 'Follow your device theme setting automatically',
                value: ThemeMode.system,
                groupValue: mode,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _optionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required ThemeMode value,
    required ThemeMode groupValue,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => setSavedTheme(value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary.withOpacity(0.42)
                : colorScheme.outlineVariant,
          ),
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
                      color: colorScheme.onSurface,
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
            Radio<ThemeMode>(
              value: value,
              groupValue: groupValue,
              onChanged: (next) {
                if (next != null) {
                  setSavedTheme(next);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
