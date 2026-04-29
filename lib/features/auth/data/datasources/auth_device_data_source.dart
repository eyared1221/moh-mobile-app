import '../../../notifications/data/push_notification_service.dart';

class AuthDeviceDataSource {
  Future<void> syncPushRegistration() {
    return PushNotificationService.instance.syncRegistrationWithBackend(
      requestPermission: true,
    );
  }
}
