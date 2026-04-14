import 'package:flutter/material.dart';

import '../../data/app_notification_service.dart';
import '../../models/app_notification.dart';

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  final AppNotificationService _service = AppNotificationService.instance;

  bool _isLoading = true;
  List<AppNotification> _notifications = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notifications = await _service.getNotifications();
    if (!mounted) return;

    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
  }

  Future<void> _markAllRead() async {
    await _service.markAllRead();
    await _load();
  }

  Future<void> _openNotification(AppNotification notification) async {
    if (!notification.isRead) {
      await _service.markRead(notification.id);
    }
    await _load();
  }

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
        title: const Text('Notification Center'),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 54,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No notifications yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Automatic alerts will appear here when there is something important to show.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final spec = _styleFor(notification, colorScheme);

                    return InkWell(
                      onTap: () => _openNotification(notification),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        decoration: BoxDecoration(
                          color: notification.isRead
                              ? theme.cardColor
                              : colorScheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: notification.isRead
                                ? colorScheme.outlineVariant
                                : colorScheme.primary.withOpacity(0.18),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: spec.background,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(spec.icon, color: spec.foreground),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notification.title,
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      if (!notification.isRead)
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.message,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatTime(notification.createdAt),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  _NotificationStyle _styleFor(AppNotification notification, ColorScheme colorScheme) {
    switch (notification.type) {
      case 'welcome':
        return _NotificationStyle(
          icon: Icons.waving_hand_rounded,
          background: colorScheme.primary.withOpacity(0.12),
          foreground: colorScheme.primary,
        );
      case 'security':
        return const _NotificationStyle(
          icon: Icons.shield_outlined,
          background: Color(0xFFF8D9CF),
          foreground: Color(0xFFB85C38),
        );
      case 'risk_assessment':
        return _NotificationStyle(
          icon: Icons.fact_check_outlined,
          background: colorScheme.primary.withOpacity(0.12),
          foreground: colorScheme.primary,
        );
      case 'learning':
        return const _NotificationStyle(
          icon: Icons.menu_book_rounded,
          background: Color(0xFFD9F1F4),
          foreground: Color(0xFF0A7C8E),
        );
      case 'reminder':
      default:
        return _NotificationStyle(
          icon: Icons.schedule_rounded,
          background: colorScheme.secondary.withOpacity(0.12),
          foreground: colorScheme.secondary,
        );
    }
  }

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours} hr ago';
    }
    if (difference.inDays == 1) {
      return 'Yesterday';
    }
    return '${difference.inDays} days ago';
  }
}

class _NotificationStyle {
  final IconData icon;
  final Color background;
  final Color foreground;

  const _NotificationStyle({
    required this.icon,
    required this.background,
    required this.foreground,
  });
}
