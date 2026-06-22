import 'package:flutter/material.dart';

import '../../data/app_notification_service.dart';
import '../../domain/entities/app_notification_entity.dart';
import '../../domain/usecases/clear_all_notifications_use_case.dart';
import '../../domain/usecases/delete_notification_use_case.dart';
import '../../domain/usecases/get_notifications_use_case.dart';
import '../../domain/usecases/mark_all_notifications_read_use_case.dart';
import '../../domain/usecases/mark_notification_read_use_case.dart';
import '../controllers/notification_center_controller.dart';

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  late final NotificationCenterController _controller;

  bool _isLoading = true;
  List<AppNotificationEntity> _notifications = const [];

  @override
  void initState() {
    super.initState();
    final repository = AppNotificationService.instance;
    _controller = NotificationCenterController(
      getNotificationsUseCase: GetNotificationsUseCase(repository),
      markAllReadUseCase: MarkAllNotificationsReadUseCase(repository),
      markReadUseCase: MarkNotificationReadUseCase(repository),
      deleteNotificationUseCase: DeleteNotificationUseCase(repository),
      clearAllNotificationsUseCase: ClearAllNotificationsUseCase(repository),
    );
    _load();
  }

  Future<void> _load() async {
    final notifications = await _controller.loadNotifications();
    if (!mounted) return;

    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
  }

  Future<void> _markAllRead() async {
    await _controller.markAllRead();
    await _load();
  }

  Future<void> _openNotification(AppNotificationEntity notification) async {
    await _controller.openNotification(notification);
    await _load();
  }

  Future<void> _deleteNotification(String id) async {
    await _controller.deleteNotification(id);
    await _load();
  }

  Future<void> _clearAllNotifications() async {
    await _controller.clearAllNotifications();
    await _load();
  }

  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Notifications'),
          content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllNotifications();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
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
        centerTitle: true,
        title: const Text('Notifications'),
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
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          final spec = _styleFor(notification, colorScheme);

                          return Dismissible(
                            key: Key(notification.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            onDismissed: (direction) {
                              _deleteNotification(notification.id);
                            },
                            child: InkWell(
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
                            ),
                          );
                        },
                      ),
                    ),
                    // Clear All button at the bottom
                    if (_notifications.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          border: Border(
                            top: BorderSide(
                              color: colorScheme.outlineVariant,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showClearAllConfirmation(),
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Clear All'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.1),
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  _NotificationStyle _styleFor(AppNotificationEntity notification, ColorScheme colorScheme) {
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
