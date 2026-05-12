import 'package:shared_preferences/shared_preferences.dart';

import '../../models/profile_user.dart';
import '../../domain/entities/notification_preferences_entity.dart';

class ProfileLocalDataSource {
  static const isLoggedInKey = 'isLoggedIn';
  static const nameKey = 'profile_full_name';
  static const ageKey = 'profile_age';
  static const emailKey = 'profile_email';
  static const phoneKey = 'profile_phone';
  static const languageKey = 'language';
  static const avatarPathKey = 'profile_avatar_path';

  static const notifyWelcomeKey = 'notify_welcome_messages';
  static const notifyPushKey = 'notify_push_notifications';
  static const notifySoundKey = 'notify_sound';
  static const notifyInactivityKey = 'notify_inactivity_reminders';
  static const notifyRiskAssessmentKey = 'notify_risk_assessment_reminders';
  static const notifyLearningKey = 'notify_learning_modules';
  static const notifySecurityKey = 'notify_security_alerts';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, value);

    if (!value) {
      await prefs.remove('authToken');
      await prefs.remove('userId');
      await prefs.remove('userEmail');
      await prefs.remove('userName');
      await prefs.remove('userAge');
    }
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<ProfileUser> getLocalProfile({
    required int fallbackAge,
    String? fallbackName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final safeAge = fallbackAge > 0 ? fallbackAge : 24;
    final storedProfileName = prefs.getString(nameKey)?.trim() ?? '';
    final storedSessionName = prefs.getString('userName')?.trim() ?? '';
    final storedProfileEmail = prefs.getString(emailKey)?.trim() ?? '';
    final storedSessionEmail = prefs.getString('userEmail')?.trim() ?? '';
    final storedSessionAge = int.tryParse(prefs.getString('userAge') ?? '');
    final resolvedEmail =
        storedProfileEmail.isNotEmpty ? storedProfileEmail : storedSessionEmail;
    final resolvedName = storedProfileName.isNotEmpty
        ? storedProfileName
        : storedSessionName.isNotEmpty
            ? storedSessionName
            : fallbackName ?? 'Alex Johnston';

    return ProfileUser(
      fullName: resolvedName,
      age: prefs.getInt(ageKey) ?? storedSessionAge ?? safeAge,
      email: resolvedEmail,
      phone: prefs.getString(phoneKey) ?? '',
      language: prefs.getString(languageKey) ?? 'English',
      avatarPath: prefs.getString(avatarPathKey),
    );
  }

  Future<bool> hasUsableLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final storedProfileName = prefs.getString(nameKey)?.trim() ?? '';
    final storedSessionName = prefs.getString('userName')?.trim() ?? '';
    final storedProfileEmail = prefs.getString(emailKey)?.trim() ?? '';
    final storedSessionEmail = prefs.getString('userEmail')?.trim() ?? '';
    final storedPhone = prefs.getString(phoneKey)?.trim() ?? '';
    final storedAvatarPath = prefs.getString(avatarPathKey)?.trim() ?? '';

    return storedProfileName.isNotEmpty ||
        storedSessionName.isNotEmpty ||
        storedProfileEmail.isNotEmpty ||
        storedSessionEmail.isNotEmpty ||
        storedPhone.isNotEmpty ||
        storedAvatarPath.isNotEmpty ||
        prefs.containsKey(ageKey) ||
        prefs.containsKey('userAge');
  }

  Future<void> cacheProfile(ProfileUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(nameKey, user.fullName);
    await prefs.setInt(ageKey, user.age);
    await prefs.setString(emailKey, user.email);
    await prefs.setString(phoneKey, user.phone);
    await saveLocalPresentationPrefs(user);
    await prefs.setString('userName', user.fullName);
    await prefs.setString('userEmail', user.email);
    await prefs.setString('userAge', user.age.toString());
  }

  Future<void> saveLocalPresentationPrefs(ProfileUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(languageKey, user.language);

    if (user.avatarPath != null && user.avatarPath!.isNotEmpty) {
      await prefs.setString(avatarPathKey, user.avatarPath!);
      return;
    }

    await prefs.remove(avatarPathKey);
  }

  Future<NotificationPreferencesEntity> getNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPreferencesEntity(
      pushEnabled: prefs.getBool(notifyPushKey) ?? true,
      welcome: prefs.getBool(notifyWelcomeKey) ?? true,
      sound: prefs.getBool(notifySoundKey) ?? true,
      inactivity: prefs.getBool(notifyInactivityKey) ?? true,
      riskAssessment: prefs.getBool(notifyRiskAssessmentKey) ?? true,
      learning: prefs.getBool(notifyLearningKey) ?? true,
      security: prefs.getBool(notifySecurityKey) ?? true,
    );
  }

  Future<void> setNotificationPreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool> coreProfileChanged(ProfileUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedName = prefs.getString(nameKey) ?? '';
    final cachedAge = prefs.getInt(ageKey) ?? 0;
    final cachedEmail = prefs.getString(emailKey) ?? '';
    final cachedPhone = prefs.getString(phoneKey) ?? '';

    return cachedName != user.fullName ||
        cachedAge != user.age ||
        cachedEmail != user.email ||
        cachedPhone != user.phone;
  }

  Future<String> getStoredLanguage({String fallback = 'English'}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(languageKey) ?? fallback;
  }

  Future<String?> getStoredAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(avatarPathKey);
  }
}
