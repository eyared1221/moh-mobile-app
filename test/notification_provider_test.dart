import 'package:flutter_test/flutter_test.dart';
import 'package:yegna_health/features/notifications/data/notification_provider.dart';

void main() {
  group('NotificationProvider Tests', () {
    late NotificationProvider provider;

    setUp(() {
      provider = NotificationProvider();
    });

    test('initial unread count should be 0', () {
      expect(provider.unreadCount, 0);
    });

    test('updateUnreadCount should update the count', () {
      provider.updateUnreadCount(5);
      expect(provider.unreadCount, 5);
    });

    test('decrementUnreadCount should decrease count when > 0', () {
      provider.updateUnreadCount(3);
      provider.decrementUnreadCount();
      expect(provider.unreadCount, 2);
    });

    test('decrementUnreadCount should not go below 0', () {
      provider.updateUnreadCount(1);
      provider.decrementUnreadCount();
      provider.decrementUnreadCount(); // Should not go negative
      expect(provider.unreadCount, 0);
    });

    test('resetUnreadCount should set count to 0', () {
      provider.updateUnreadCount(10);
      provider.resetUnreadCount();
      expect(provider.unreadCount, 0);
    });

    test('updateUnreadCount should not notify when count is same', () {
      provider.updateUnreadCount(5);
      bool wasNotified = false;
      provider.addListener(() {
        wasNotified = true;
      });
      
      provider.updateUnreadCount(5); // Same count
      expect(wasNotified, false);
    });

    test('updateUnreadCount should notify when count changes', () {
      provider.updateUnreadCount(5);
      bool wasNotified = false;
      provider.addListener(() {
        wasNotified = true;
      });
      
      provider.updateUnreadCount(3); // Different count
      expect(wasNotified, true);
    });
  });
}
