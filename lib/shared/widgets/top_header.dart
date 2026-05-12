import 'package:flutter/material.dart';

import '../../core/theme/theme_notifier.dart';
import 'global_notification_bell.dart';

class TopHeader extends StatelessWidget {
  final VoidCallback? onBellTap;
  final SyncActionCallback? onSyncPressed;
  final Widget? rightWidget;
  final bool showBack;
  final bool showThemeToggle;

  const TopHeader({
    super.key,
    this.onBellTap,
    this.onSyncPressed,
    this.rightWidget,
    this.showBack = false,
    this.showThemeToggle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconColor = colorScheme.primary;
    final titleStyle =
        theme.textTheme.titleLarge?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w800,
        ) ??
        TextStyle(
          color: colorScheme.primary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        );

    return Row(
      children: [
        if (showBack)
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: iconColor,
            onPressed: () => Navigator.pop(context),
          ),
        Image.asset(
          'assets/images/logo.png',
          width: 48,
          height: 48,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Text('yegna Health', style: titleStyle),
        const Spacer(),
        if (showThemeToggle)
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark ||
                  (mode == ThemeMode.system &&
                      Theme.of(context).brightness == Brightness.dark);
              return IconButton(
                onPressed: toggleTheme,
                icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                color: colorScheme.primary,
                tooltip: 'Toggle theme',
              );
            },
          ),
        rightWidget ??
            GlobalTopBarActions(
              onBellPressed: onBellTap,
              onSyncPressed: onSyncPressed,
              color: iconColor,
              iconSize: 28,
            ),
      ],
    );
  }
}
