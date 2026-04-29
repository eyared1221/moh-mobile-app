import '../entities/notification_preferences_entity.dart';
import '../entities/profile_user_entity.dart';

abstract class ProfileRepository {
  bool get isPushSupported;

  Future<bool> isLoggedIn();

  Future<void> setLoggedIn(bool value);

  Future<ProfileUserEntity> fetchProfile({
    required int fallbackAge,
    String? fallbackName,
  });

  Future<ProfileUserEntity> saveProfile(ProfileUserEntity user);

  Future<NotificationPreferencesEntity> fetchNotificationPreferences();

  Future<void> setNotificationPreference(String key, bool value);

  Future<bool> setPushEnabled(bool enabled);

  Future<void> logout();
}
