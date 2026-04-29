import '../../data/profile_repository.dart';
import '../../domain/entities/notification_preferences_entity.dart';
import '../../domain/entities/profile_user_entity.dart';
import '../../domain/usecases/fetch_notification_preferences_use_case.dart';
import '../../domain/usecases/fetch_profile_use_case.dart';
import '../../domain/usecases/is_logged_in_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/save_profile_use_case.dart';
import '../../domain/usecases/set_notification_preference_use_case.dart';
import '../../domain/usecases/set_push_enabled_use_case.dart';

class ProfileController {
  const ProfileController({
    required IsLoggedInUseCase isLoggedInUseCase,
    required FetchProfileUseCase fetchProfileUseCase,
    required SaveProfileUseCase saveProfileUseCase,
    required FetchNotificationPreferencesUseCase fetchNotificationPreferencesUseCase,
    required SetNotificationPreferenceUseCase setNotificationPreferenceUseCase,
    required SetPushEnabledUseCase setPushEnabledUseCase,
    required LogoutUseCase logoutUseCase,
    required this.isPushSupported,
    required this.notifyWelcomeKey,
    required this.notifyPushKey,
    required this.notifySoundKey,
    required this.notifyInactivityKey,
    required this.notifyRiskAssessmentKey,
    required this.notifyLearningKey,
    required this.notifySecurityKey,
  }) : _isLoggedInUseCase = isLoggedInUseCase,
       _fetchProfileUseCase = fetchProfileUseCase,
       _saveProfileUseCase = saveProfileUseCase,
       _fetchNotificationPreferencesUseCase =
           fetchNotificationPreferencesUseCase,
       _setNotificationPreferenceUseCase = setNotificationPreferenceUseCase,
       _setPushEnabledUseCase = setPushEnabledUseCase,
       _logoutUseCase = logoutUseCase;

  factory ProfileController.standard() {
    final repository = ProfileRepository();
    return ProfileController(
      isLoggedInUseCase: IsLoggedInUseCase(repository),
      fetchProfileUseCase: FetchProfileUseCase(repository),
      saveProfileUseCase: SaveProfileUseCase(repository),
      fetchNotificationPreferencesUseCase:
          FetchNotificationPreferencesUseCase(repository),
      setNotificationPreferenceUseCase:
          SetNotificationPreferenceUseCase(repository),
      setPushEnabledUseCase: SetPushEnabledUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
      isPushSupported: repository.isPushSupported,
      notifyWelcomeKey: repository.notifyWelcomeKey,
      notifyPushKey: repository.notifyPushKey,
      notifySoundKey: repository.notifySoundKey,
      notifyInactivityKey: repository.notifyInactivityKey,
      notifyRiskAssessmentKey: repository.notifyRiskAssessmentKey,
      notifyLearningKey: repository.notifyLearningKey,
      notifySecurityKey: repository.notifySecurityKey,
    );
  }

  final IsLoggedInUseCase _isLoggedInUseCase;
  final FetchProfileUseCase _fetchProfileUseCase;
  final SaveProfileUseCase _saveProfileUseCase;
  final FetchNotificationPreferencesUseCase
      _fetchNotificationPreferencesUseCase;
  final SetNotificationPreferenceUseCase _setNotificationPreferenceUseCase;
  final SetPushEnabledUseCase _setPushEnabledUseCase;
  final LogoutUseCase _logoutUseCase;

  final bool isPushSupported;
  final String notifyWelcomeKey;
  final String notifyPushKey;
  final String notifySoundKey;
  final String notifyInactivityKey;
  final String notifyRiskAssessmentKey;
  final String notifyLearningKey;
  final String notifySecurityKey;

  Future<bool> isLoggedIn() {
    return _isLoggedInUseCase();
  }

  Future<ProfileUserEntity> loadProfile({
    required int fallbackAge,
    String? fallbackName,
  }) {
    return _fetchProfileUseCase(
      fallbackAge: fallbackAge,
      fallbackName: fallbackName,
    );
  }

  Future<ProfileUserEntity> saveProfile(ProfileUserEntity profile) {
    return _saveProfileUseCase(profile);
  }

  Future<NotificationPreferencesEntity> loadNotificationPreferences() {
    return _fetchNotificationPreferencesUseCase();
  }

  Future<void> setNotificationPreference(String key, bool value) {
    return _setNotificationPreferenceUseCase(key, value);
  }

  Future<bool> setPushEnabled(bool enabled) {
    return _setPushEnabledUseCase(enabled);
  }

  Future<void> logout() {
    return _logoutUseCase();
  }
}
