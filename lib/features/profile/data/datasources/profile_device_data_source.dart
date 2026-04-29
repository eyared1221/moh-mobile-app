import '../../../notifications/data/push_notification_service.dart';

class ProfileDeviceDataSource {
  bool get isPushSupported => PushNotificationService.isSupportedPlatform;

  Future<bool> setPushEnabled(bool enabled) {
    return PushNotificationService.instance.setPushEnabled(enabled);
  }

  Future<void> unregisterCurrentDevice() {
    return PushNotificationService.instance.unregisterCurrentDevice();
  }
}
