import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../profile/data/profile_repository.dart';
import '../models/app_notification.dart';

class AppNotificationService {
  AppNotificationService({
    ProfileRepository? profileRepository,
  }) : _profileRepository = profileRepository ?? ProfileRepository();

  static const _storageKey = 'app_notifications';

  static final AppNotificationService instance = AppNotificationService();

  final ProfileRepository _profileRepository;

  Future<List<AppNotification>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);

    if (stored == null || stored.isEmpty) {
      final seeded = await _buildDefaultNotifications();
      await _persist(prefs, seeded);
      return seeded;
    }

    final decoded = jsonDecode(stored);
    if (decoded is! List) {
      final seeded = await _buildDefaultNotifications();
      await _persist(prefs, seeded);
      return seeded;
    }

    final notifications = decoded
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return notifications;
  }

  Future<void> markRead(String id) async {
    final notifications = await getNotifications();
    final updated = notifications
        .map(
          (notification) => notification.id == id && !notification.isRead
              ? notification.copyWith(readAt: DateTime.now())
              : notification,
        )
        .toList();

    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs, updated);
  }

  Future<void> markAllRead() async {
    final notifications = await getNotifications();
    final now = DateTime.now();
    final updated = notifications
        .map(
          (notification) => notification.isRead
              ? notification
              : notification.copyWith(readAt: now),
        )
        .toList();

    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs, updated);
  }

  Future<List<AppNotification>> _buildDefaultNotifications() async {
    final enabledPrefs = await _profileRepository.fetchNotificationPrefs();
    final now = DateTime.now();
    final notifications = <AppNotification>[];

    if (enabledPrefs[_profileRepository.notifyWelcomeKey] ?? true) {
      notifications.add(
        AppNotification(
          id: 'welcome-message',
          type: 'welcome',
          title: 'Welcome back',
          message: 'Your health dashboard is ready. Continue where you left off.',
          createdAt: now.subtract(const Duration(minutes: 10)),
        ),
      );
    }

    if (enabledPrefs[_profileRepository.notifyRiskAssessmentKey] ?? true) {
      notifications.add(
        AppNotification(
          id: 'risk-assessment-reminder',
          type: 'risk_assessment',
          title: 'Risk assessment reminder',
          message: 'A quick check-in can help you stay on top of your health goals.',
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
      );
    }

    if (enabledPrefs[_profileRepository.notifyLearningKey] ?? true) {
      notifications.add(
        AppNotification(
          id: 'learning-update',
          type: 'learning',
          title: 'New learning content available',
          message: 'Open the learning section to review the latest guidance and tips.',
          createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        ),
      );
    }

    if (enabledPrefs[_profileRepository.notifySecurityKey] ?? true) {
      notifications.add(
        AppNotification(
          id: 'security-alert',
          type: 'security',
          title: 'Account security check',
          message: 'Review your profile details to keep your account information current.',
          createdAt: now.subtract(const Duration(days: 2, hours: 6)),
        ),
      );
    }

    if (enabledPrefs[_profileRepository.notifyInactivityKey] ?? true) {
      notifications.add(
        AppNotification(
          id: 'inactivity-reminder',
          type: 'reminder',
          title: 'It has been a while',
          message: 'Come back for a quick review and keep your progress moving.',
          createdAt: now.subtract(const Duration(days: 4)),
        ),
      );
    }

    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  Future<void> _persist(
    SharedPreferences prefs,
    List<AppNotification> notifications,
  ) {
    final encoded = jsonEncode(
      notifications.map((notification) => notification.toJson()).toList(),
    );
    return prefs.setString(_storageKey, encoded);
  }
}
