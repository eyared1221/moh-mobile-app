import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_user.dart';
import 'profile_api_client.dart';

class ProfileRepository {
  ProfileRepository({ProfileApiClient? apiClient})
      : _apiClient = apiClient ?? ProfileApiClient();

  static const _isLoggedInKey = 'isLoggedIn';
  static const _nameKey = 'profile_full_name';
  static const _ageKey = 'profile_age';
  static const _emailKey = 'profile_email';
  static const _phoneKey = 'profile_phone';
  static const _languageKey = 'language';
  static const _avatarPathKey = 'profile_avatar_path';

  static const _notifyWelcomeKey = 'notify_welcome_messages';
  static const _notifySoundKey = 'notify_sound';
  static const _notifyInactivityKey = 'notify_inactivity_reminders';
  static const _notifyRiskAssessmentKey = 'notify_risk_assessment_reminders';
  static const _notifyLearningKey = 'notify_learning_modules';
  static const _notifySecurityKey = 'notify_security_alerts';

  final ProfileApiClient _apiClient;

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);

    if (!value) {
      await prefs.remove('authToken');
      await prefs.remove('userId');
      await prefs.remove('userEmail');
      await prefs.remove('userName');
      await prefs.remove('userAge');
    }
  }

  Future<ProfileUser> fetchProfile({
    required int fallbackAge,
    String? fallbackName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final localProfile = _profileFromPrefs(
      prefs,
      fallbackAge: fallbackAge,
      fallbackName: fallbackName,
    );
    final authToken = prefs.getString('authToken');

    if (!(prefs.getBool(_isLoggedInKey) ?? false) || authToken == null || authToken.isEmpty) {
      return localProfile;
    }

    try {
      final payload = await _apiClient.get('/profile');
      final data = payload['data'] as Map<String, dynamic>? ?? const <String, dynamic>{};
      final remoteProfile = await profileFromBackendJson(
        data,
        fallbackAge: fallbackAge,
        fallbackName: fallbackName,
      );
      final mergedProfile = remoteProfile.copyWith(
        language: prefs.getString(_languageKey) ?? localProfile.language,
        avatarPath: prefs.getString(_avatarPathKey) ?? localProfile.avatarPath,
      );

      await _cacheProfile(prefs, mergedProfile);
      return mergedProfile;
    } catch (_) {
      return localProfile;
    }
  }

  Future<ProfileUser> saveProfile(ProfileUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await _saveLocalPresentationPrefs(prefs, user);

    final authToken = prefs.getString('authToken');
    final loggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    final needsRemoteUpdate = _coreProfileChanged(prefs, user);

    if (!loggedIn || authToken == null || authToken.isEmpty || !needsRemoteUpdate) {
      await _cacheProfile(prefs, user);
      return user;
    }

    final payload = await _apiClient.put('/profile', profileToBackendJson(user));
    final data = payload['data'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final savedProfile = await profileFromBackendJson(
      data,
      fallbackAge: user.age,
      fallbackName: user.fullName,
    );
    final mergedProfile = savedProfile.copyWith(
      language: user.language,
      avatarPath: user.avatarPath,
    );

    await _cacheProfile(prefs, mergedProfile);
    return mergedProfile;
  }

  Future<ProfileUser> profileFromBackendJson(
    Map<String, dynamic> json, {
    required int fallbackAge,
    String? fallbackName,
  }) async {
    final parsed = ProfileUser.fromJson(json);
    return parsed.copyWith(
      fullName: parsed.fullName.isEmpty ? (fallbackName ?? 'Alex Johnston') : null,
      age: parsed.age == 0 ? fallbackAge : null,
      language: parsed.language.isEmpty ? 'English' : null,
    );
  }

  Map<String, dynamic> profileToBackendJson(ProfileUser user) {
    final payload = <String, dynamic>{
      'username': user.fullName.trim(),
      'age': user.age,
    };

    final email = user.email.trim();
    final phone = user.phone.trim();

    if (email.isNotEmpty) {
      payload['email'] = email;
    }

    if (phone.isNotEmpty) {
      payload['phone'] = phone;
    }

    return payload;
  }

  Future<Map<String, bool>> fetchNotificationPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      _notifyWelcomeKey: prefs.getBool(_notifyWelcomeKey) ?? true,
      _notifySoundKey: prefs.getBool(_notifySoundKey) ?? true,
      _notifyInactivityKey: prefs.getBool(_notifyInactivityKey) ?? true,
      _notifyRiskAssessmentKey: prefs.getBool(_notifyRiskAssessmentKey) ?? true,
      _notifyLearningKey: prefs.getBool(_notifyLearningKey) ?? true,
      _notifySecurityKey: prefs.getBool(_notifySecurityKey) ?? true,
    };
  }

  Future<void> setNotificationPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  String get notifyWelcomeKey => _notifyWelcomeKey;
  String get notifySoundKey => _notifySoundKey;
  String get notifyInactivityKey => _notifyInactivityKey;
  String get notifyRiskAssessmentKey => _notifyRiskAssessmentKey;
  String get notifyLearningKey => _notifyLearningKey;
  String get notifySecurityKey => _notifySecurityKey;

  ProfileUser _profileFromPrefs(
    SharedPreferences prefs, {
    required int fallbackAge,
    String? fallbackName,
  }) {
    final safeAge = fallbackAge > 0 ? fallbackAge : 24;
    return ProfileUser(
      fullName: prefs.getString(_nameKey) ?? fallbackName ?? 'Alex Johnston',
      age: prefs.getInt(_ageKey) ?? safeAge,
      email: prefs.getString(_emailKey) ?? '',
      phone: prefs.getString(_phoneKey) ?? '',
      language: prefs.getString(_languageKey) ?? 'English',
      avatarPath: prefs.getString(_avatarPathKey),
    );
  }

  Future<void> _cacheProfile(SharedPreferences prefs, ProfileUser user) async {
    await prefs.setString(_nameKey, user.fullName);
    await prefs.setInt(_ageKey, user.age);
    await prefs.setString(_emailKey, user.email);
    await prefs.setString(_phoneKey, user.phone);
    await _saveLocalPresentationPrefs(prefs, user);
    await prefs.setString('userName', user.fullName);
    await prefs.setString('userEmail', user.email);
    await prefs.setString('userAge', user.age.toString());
  }

  Future<void> _saveLocalPresentationPrefs(
    SharedPreferences prefs,
    ProfileUser user,
  ) async {
    await prefs.setString(_languageKey, user.language);

    if (user.avatarPath != null && user.avatarPath!.isNotEmpty) {
      await prefs.setString(_avatarPathKey, user.avatarPath!);
      return;
    }

    await prefs.remove(_avatarPathKey);
  }

  bool _coreProfileChanged(SharedPreferences prefs, ProfileUser user) {
    final cachedName = prefs.getString(_nameKey) ?? '';
    final cachedAge = prefs.getInt(_ageKey) ?? 0;
    final cachedEmail = prefs.getString(_emailKey) ?? '';
    final cachedPhone = prefs.getString(_phoneKey) ?? '';

    return cachedName != user.fullName ||
        cachedAge != user.age ||
        cachedEmail != user.email ||
        cachedPhone != user.phone;
  }
}
