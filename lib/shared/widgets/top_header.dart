import 'package:flutter/material.dart';
import '../../core/theme/theme_notifier.dart';
import '../../features/notifications/data/app_notification_service.dart';
import '../../features/notifications/data/notification_provider.dart';
import 'notification_badge.dart';

class TopHeader extends StatefulWidget {
  /// Optional tap for notification bell
  final VoidCallback? onBellTap;

  /// Optional widget on the right side (overrides bell)
  final Widget? rightWidget;

  /// Show back arrow (for sub pages like Causes, Prevention, Description)
  final bool showBack;
  /// Show theme toggle button in this header
  final bool showThemeToggle;

  const TopHeader({
    super.key,
    this.onBellTap,
    this.rightWidget,
    this.showBack = false,
    this.showThemeToggle = false,
  });

  @override
  State<TopHeader> createState() => _TopHeaderState();
}

class _TopHeaderState extends State<TopHeader> {
  final AppNotificationService _notificationService = AppNotificationService.instance;
  final NotificationProvider _provider = NotificationProvider();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _unreadCount = _provider.unreadCount;
    _loadUnreadCount();
    _provider.addListener(_onNotificationCountChanged);
  }

  @override
  void dispose() {
    _provider.removeListener(_onNotificationCountChanged);
    super.dispose();
  }

  void _onNotificationCountChanged() {
    if (mounted) {
      setState(() {
        _unreadCount = _provider.unreadCount;
      });
    }
  }

  Future<void> _loadUnreadCount() async {
    await _notificationService.getUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ✅ Back button (only when enabled)
        if (widget.showBack)
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
        if (widget.showThemeToggle)
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
        widget.rightWidget ??
            NotificationBadge(
              count: _unreadCount,
              child: IconButton(
                onPressed: widget.onBellTap,
                icon: const Icon(Icons.notifications_none),
                color: const Color(0xFF005C8F),
                iconSize: 28,
                tooltip: 'Notifications',
              ),
            ),
      ],
    );
  }
}
