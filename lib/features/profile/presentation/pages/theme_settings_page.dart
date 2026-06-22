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
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 10),

              _themeSection(
                context,
                children: [
                  _optionTile(
                    context,
                    title: 'Light Mode',
                    value: ThemeMode.light,
                    groupValue: mode,
                  ),

                  _sectionDivider(colorScheme),

                  _optionTile(
                    context,
                    title: 'Dark Mode',
                    value: ThemeMode.dark,
                    groupValue: mode,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _themeSection(
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

  Widget _optionTile(
    BuildContext context, {
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => setSavedTheme(value),
      child: Padding(
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
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 3),

                
                ],
              ),
            ),

            Radio<ThemeMode>(
              value: value,
              groupValue: groupValue,
              activeColor: colorScheme.primary,
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