import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yegna_health/features/notifications/data/app_notification_service.dart';
import 'package:yegna_health/features/notifications/data/notification_automation_service.dart';
import 'package:yegna_health/features/notifications/data/push_notification_service.dart';
import 'package:yegna_health/features/notifications/domain/entities/app_notification_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppNotificationService notificationService;
  late FakePushNotificationService pushNotificationService;
  late NotificationAutomationService automationService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    notificationService = AppNotificationService();
    pushNotificationService = FakePushNotificationService();
    automationService = NotificationAutomationService(
      notificationService: notificationService,
      pushNotificationService: pushNotificationService,
    );
  });

  test('manual sync restores due risk reminder and schedules future ones', () async {
    final baseline = DateTime.now().subtract(const Duration(days: 8));
    SharedPreferences.setMockInitialValues({
      'isLoggedIn': true,
      'notifications_last_risk_assessment_at': baseline.toIso8601String(),
      'notifications_risk_reminder_start_at': baseline.toIso8601String(),
      'notify_risk_assessment_reminders': true,
    });
    notificationService = AppNotificationService();
    pushNotificationService = FakePushNotificationService();
    automationService = NotificationAutomationService(
      notificationService: notificationService,
      pushNotificationService: pushNotificationService,
    );

    await automationService.handleManualSync();

    final notifications = await notificationService.getNotifications();

    expect(notifications.where((n) => n.type == 'risk_assessment'), hasLength(1));
    expect(notifications.single.id, contains('day-7'));
    expect(pushNotificationService.scheduledNotificationIds, hasLength(2));
    expect(
      pushNotificationService.scheduledNotificationIds.every(
        (id) => id.contains('day-14') || id.contains('day-30'),
      ),
      isTrue,
    );
  });

  test('manual sync cancels risk schedules when the preference is disabled', () async {
    final baseline = DateTime.now().subtract(const Duration(days: 2));
    SharedPreferences.setMockInitialValues({
      'isLoggedIn': true,
      'notifications_last_risk_assessment_at': baseline.toIso8601String(),
      'notifications_risk_reminder_start_at': baseline.toIso8601String(),
      'notify_risk_assessment_reminders': false,
    });
    notificationService = AppNotificationService();
    pushNotificationService = FakePushNotificationService();
    automationService = NotificationAutomationService(
      notificationService: notificationService,
      pushNotificationService: pushNotificationService,
    );

    await automationService.handleManualSync();

    final notifications = await notificationService.getNotifications();

    expect(notifications.where((n) => n.type == 'risk_assessment'), isEmpty);
    expect(pushNotificationService.cancelledNotificationIds, hasLength(3));
  });
}

class FakePushNotificationService extends PushNotificationService {
  final List<String> scheduledNotificationIds = <String>[];
  final List<String> cancelledNotificationIds = <String>[];

  @override
  Future<void> scheduleLocalAppNotification(
    AppNotificationEntity notification, {
    required DateTime scheduledAt,
    bool requestPermission = false,
  }) async {
    scheduledNotificationIds.add(notification.id);
  }

  @override
  Future<void> cancelLocalAppNotification(String notificationId) async {
    cancelledNotificationIds.add(notificationId);
  }

  @override
  Future<void> showLocalAppNotification(
    AppNotificationEntity notification, {
    bool requestPermission = false,
  }) async {}
}
