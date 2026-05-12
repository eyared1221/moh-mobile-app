import '../domain/entities/notification_preferences_entity.dart';
import '../domain/entities/profile_user_entity.dart';
import 'datasources/profile_device_data_source.dart';
import 'datasources/profile_local_data_source.dart';
import 'datasources/profile_remote_data_source.dart';
import 'repositories/profile_repository_impl.dart';

class ProfileRepository extends ProfileRepositoryImpl {
  ProfileRepository({
    super.remoteDataSource,
    super.localDataSource,
    super.deviceDataSource,
  });

  String get notifyWelcomeKey => ProfileLocalDataSource.notifyWelcomeKey;
  String get notifyPushKey => ProfileLocalDataSource.notifyPushKey;
  String get notifySoundKey => ProfileLocalDataSource.notifySoundKey;
  String get notifyInactivityKey => ProfileLocalDataSource.notifyInactivityKey;
  String get notifyRiskAssessmentKey =>
      ProfileLocalDataSource.notifyRiskAssessmentKey;
  String get notifyLearningKey => ProfileLocalDataSource.notifyLearningKey;
  String get notifySecurityKey => ProfileLocalDataSource.notifySecurityKey;

  @override
  Future<ProfileUserEntity> fetchProfile({
    required int fallbackAge,
    String? fallbackName,
  }) {
    return super.fetchProfile(
      fallbackAge: fallbackAge,
      fallbackName: fallbackName,
    );
  }

  @override
  Future<ProfileUserEntity?> fetchCachedProfile({
    required int fallbackAge,
    String? fallbackName,
  }) {
    return super.fetchCachedProfile(
      fallbackAge: fallbackAge,
      fallbackName: fallbackName,
    );
  }

  @override
  Future<ProfileUserEntity> saveProfile(ProfileUserEntity user) {
    return super.saveProfile(user);
  }

  Future<Map<String, bool>> fetchNotificationPrefs() async {
    final prefs = await fetchNotificationPreferences();
    return {
      notifyPushKey: prefs.pushEnabled,
      notifyWelcomeKey: prefs.welcome,
      notifySoundKey: prefs.sound,
      notifyInactivityKey: prefs.inactivity,
      notifyRiskAssessmentKey: prefs.riskAssessment,
      notifyLearningKey: prefs.learning,
      notifySecurityKey: prefs.security,
    };
  }

  Future<void> setNotificationPref(String key, bool value) {
    return setNotificationPreference(key, value);
  }

  @override
  Future<NotificationPreferencesEntity> fetchNotificationPreferences() {
    return super.fetchNotificationPreferences();
  }
}
