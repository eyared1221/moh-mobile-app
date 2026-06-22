import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yegna_health/features/notifications/data/app_notification_service.dart';
import 'package:yegna_health/features/notifications/models/app_notification.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppNotificationService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = AppNotificationService();
  });

  test('addNotificationIfNew stores a notification only once', () async {
    final notification = AppNotification(
      id: 'welcome-1',
      type: 'welcome',
      title: 'Welcome',
      message: 'Hello there',
      createdAt: DateTime(2026, 6, 5),
    );

    final firstInsert = await service.addNotificationIfNew(notification);
    final secondInsert = await service.addNotificationIfNew(notification);
    final storedNotifications = await service.getNotifications();

    expect(firstInsert, isNotNull);
    expect(secondInsert, isNull);
    expect(storedNotifications, hasLength(1));
    expect(storedNotifications.single.id, notification.id);
  });

  test('addNotificationIfNew respects disabled notification types', () async {
    SharedPreferences.setMockInitialValues({
      'notify_welcome_messages': false,
    });
    service = AppNotificationService();

    final result = await service.addNotificationIfNew(
      AppNotification(
        id: 'welcome-2',
        type: 'welcome',
        title: 'Welcome',
        message: 'Hello there',
        createdAt: DateTime(2026, 6, 5),
      ),
    );

    final storedNotifications = await service.getNotifications();

    expect(result, isNull);
    expect(storedNotifications, isEmpty);
  });
}
