import 'package:flutter/material.dart';
import '../../core/theme/theme_notifier.dart';
import 'global_notification_bell.dart';

class TopHeader extends StatelessWidget {
  /// Optional tap for notification bell
  final VoidCallback? onBellTap;
  final SyncActionCallback? onSyncPressed;

  /// Optional widget on the right side (overrides bell)
  final Widget? rightWidget;

  /// Show back arrow (for sub pages like Causes, Prevention, Description)
  final bool showBack;
  /// Show theme toggle button in this header
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
    return Row(
      children: [
        // ✅ Back button (only when enabled)
        if (showBack)
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: const Color(0xFF005C8F),
            onPressed: () => Navigator.pop(context),
          ),

        // App logo
        Image.asset(
          'assets/images/logo.png',
          width: 48,
          height: 48,
          fit: BoxFit.contain,
        ),

        const SizedBox(width: 10),

        // App name
        const Text(
          'yegna Health',
          style: TextStyle(
            color: Color(0xFF003D6E),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),

        const Spacer(),

        // Theme toggle (optional per screen)
        if (showThemeToggle)
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark || (mode == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
              return IconButton(
                onPressed: () => toggleTheme(),
                icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                color: Theme.of(context).colorScheme.primary,
                tooltip: 'Toggle theme',
              );
            },
          ),

        // Right side: bell OR custom widget
        rightWidget ??
            GlobalTopBarActions(
              onBellPressed: onBellTap,
              onSyncPressed: onSyncPressed,
              color: const Color(0xFF005C8F),
              iconSize: 28,
            ),
      ],
    );
  }
}
