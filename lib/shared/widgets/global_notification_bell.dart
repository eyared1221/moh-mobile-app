import 'package:flutter/material.dart';

import '../../features/notifications/data/app_notification_service.dart';
import '../../features/notifications/data/notification_automation_service.dart';
import '../../features/notifications/data/notification_provider.dart';
import '../../features/notifications/presentation/pages/notification_center_page.dart';
import 'notification_badge.dart';

typedef SyncActionCallback = Future<void> Function();

class GlobalNotificationBell extends StatefulWidget {
  const GlobalNotificationBell({
    super.key,
    this.color,
    this.iconSize,
    this.onPressed,
    this.tooltip = 'Notifications',
  });

  final Color? color;
  final double? iconSize;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  State<GlobalNotificationBell> createState() => _GlobalNotificationBellState();
}

class _GlobalNotificationBellState extends State<GlobalNotificationBell> {
  final AppNotificationService _notificationService =
      AppNotificationService.instance;
  final NotificationProvider _provider = NotificationProvider();

  @override
  void initState() {
    super.initState();
    _provider.addListener(_onNotificationCountChanged);
    _refreshUnreadCount();
  }

  @override
  void dispose() {
    _provider.removeListener(_onNotificationCountChanged);
    super.dispose();
  }

  void _onNotificationCountChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshUnreadCount() async {
    await _notificationService.getUnreadCount();
  }

  void _openNotifications() {
    if (widget.onPressed != null) {
      widget.onPressed!();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationCenterPage()),
    ).then((_) => _refreshUnreadCount());
  }

  @override
  Widget build(BuildContext context) {
    return NotificationBadge(
      count: _provider.unreadCount,
      child: IconButton(
        onPressed: _openNotifications,
        icon: const Icon(Icons.notifications_none),
        color: widget.color,
        iconSize: widget.iconSize,
        tooltip: widget.tooltip,
      ),
    );
  }
}

class GlobalTopBarActions extends StatefulWidget {
  const GlobalTopBarActions({
    super.key,
    this.color,
    this.iconSize,
    this.onBellPressed,
    this.onSyncPressed,
  });

  final Color? color;
  final double? iconSize;
  final VoidCallback? onBellPressed;
  final SyncActionCallback? onSyncPressed;

  @override
  State<GlobalTopBarActions> createState() => _GlobalTopBarActionsState();
}

class _GlobalTopBarActionsState extends State<GlobalTopBarActions> {
  final AppNotificationService _notificationService =
      AppNotificationService.instance;
  final NotificationAutomationService _automationService =
      NotificationAutomationService.instance;
  bool _isSyncing = false;

  Future<void> _syncNotifications() async {
    if (_isSyncing) {
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      if (widget.onSyncPressed != null) {
        await widget.onSyncPressed!();
      }
      await _automationService.handleManualSync();
      await _notificationService.getUnreadCount();
      if (!mounted) return;
      _showSyncFeedback(context, message: 'Sync Finished');
    } catch (_) {
      if (!mounted) return;
      _showSyncFeedback(context, message: 'Sync failed');
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlobalNotificationBell(
          onPressed: widget.onBellPressed,
          color: widget.color,
          iconSize: widget.iconSize,
        ),
        IconButton(
          onPressed: _isSyncing ? null : _syncNotifications,
          icon: _isSyncing
              ? SizedBox(
                  width: (widget.iconSize ?? 24) * 0.8,
                  height: (widget.iconSize ?? 24) * 0.8,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.color ?? Theme.of(context).colorScheme.primary,
                  ),
                )
              : const Icon(Icons.sync),
          color: widget.color,
          iconSize: widget.iconSize,
          tooltip: 'Sync',
        ),
      ],
    );
  }
}

void _showSyncFeedback(
  BuildContext context, {
  required String message,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  const accentColor = Color(0xFF005C8F);
  final messenger = ScaffoldMessenger.of(context);

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        elevation: 0,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF101726) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.28 : 0.10),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: accentColor.withOpacity(isDark ? 0.40 : 0.20),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(isDark ? 0.22 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
}
