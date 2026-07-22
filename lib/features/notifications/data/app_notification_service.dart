import 'repositories/app_notification_repository_impl.dart';

class AppNotificationService extends AppNotificationRepositoryImpl {
  AppNotificationService({
    super.localDataSource,
    super.provider,
  });

  static final AppNotificationService instance = AppNotificationService();
}
