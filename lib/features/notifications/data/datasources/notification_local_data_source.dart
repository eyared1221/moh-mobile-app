import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_notification.dart';

class NotificationLocalDataSource {
  static const storageKey = 'app_notifications';

  Future<List<AppNotification>?> getStoredNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(storageKey);

    if (stored == null || stored.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(stored);
    if (decoded is! List) {
      return null;
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> persistNotifications(List<AppNotification> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      notifications.map((notification) => notification.toJson()).toList(),
    );
    await prefs.setString(storageKey, encoded);
  }
}
