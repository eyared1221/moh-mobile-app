import '../../domain/entities/notification_preferences_entity.dart';
import '../../domain/entities/profile_user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../models/profile_user.dart';
import '../datasources/profile_device_data_source.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    ProfileRemoteDataSource? remoteDataSource,
    ProfileLocalDataSource? localDataSource,
    ProfileDeviceDataSource? deviceDataSource,
  }) : _remoteDataSource = remoteDataSource ?? ProfileRemoteDataSource(),
       _localDataSource = localDataSource ?? ProfileLocalDataSource(),
       _deviceDataSource = deviceDataSource ?? ProfileDeviceDataSource();

  final ProfileRemoteDataSource _remoteDataSource;
  final ProfileLocalDataSource _localDataSource;
  final ProfileDeviceDataSource _deviceDataSource;

  @override
  bool get isPushSupported => _deviceDataSource.isPushSupported;

  @override
  Future<bool> isLoggedIn() {
    return _localDataSource.isLoggedIn();
  }

  @override
  Future<void> setLoggedIn(bool value) {
    return _localDataSource.setLoggedIn(value);
  }

  @override
  Future<ProfileUserEntity> fetchProfile({
    required int fallbackAge,
    String? fallbackName,
  }) async {
    final localProfile = await _localDataSource.getLocalProfile(
      fallbackAge: fallbackAge,
      fallbackName: fallbackName,
    );
    final authToken = await _localDataSource.getAuthToken();

    if (!(await _localDataSource.isLoggedIn()) ||
        authToken == null ||
        authToken.isEmpty) {
      return localProfile;
    }

    try {
      final payload = await _remoteDataSource.fetchProfilePayload();
      final data = payload['data'] as Map<String, dynamic>? ?? const <String, dynamic>{};
      final remoteProfile = _remoteDataSource.profileFromBackendJson(
        data,
        fallbackAge: fallbackAge,
        fallbackName: fallbackName,
      );
      final mergedProfile = remoteProfile.copyWith(
        email: remoteProfile.email.isEmpty ? localProfile.email : null,
        phone: remoteProfile.phone.isEmpty ? localProfile.phone : null,
        language: await _localDataSource.getStoredLanguage(
          fallback: localProfile.language,
        ),
        avatarPath:
            await _localDataSource.getStoredAvatarPath() ?? localProfile.avatarPath,
      );

      await _localDataSource.cacheProfile(mergedProfile);
      return mergedProfile;
    } catch (_) {
      return localProfile;
    }
  }

  @override
  Future<ProfileUserEntity> saveProfile(ProfileUserEntity user) async {
    final profile = user is ProfileUser
        ? user
        : ProfileUser(
            fullName: user.fullName,
            age: user.age,
            email: user.email,
            phone: user.phone,
            language: user.language,
            avatarPath: user.avatarPath,
          );

    await _localDataSource.saveLocalPresentationPrefs(profile);

    final authToken = await _localDataSource.getAuthToken();
    final loggedIn = await _localDataSource.isLoggedIn();
    final needsRemoteUpdate = await _localDataSource.coreProfileChanged(profile);

    if (!loggedIn || authToken == null || authToken.isEmpty || !needsRemoteUpdate) {
      await _localDataSource.cacheProfile(profile);
      return profile;
    }

    final payload = await _remoteDataSource.saveProfilePayload(profile);
    final data = payload['data'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final savedProfile = _remoteDataSource.profileFromBackendJson(
      data,
      fallbackAge: profile.age,
      fallbackName: profile.fullName,
    );
    final mergedProfile = savedProfile.copyWith(
      email: savedProfile.email.isEmpty ? profile.email : null,
      phone: savedProfile.phone.isEmpty ? profile.phone : null,
      language: profile.language,
      avatarPath: profile.avatarPath,
    );

    await _localDataSource.cacheProfile(mergedProfile);
    return mergedProfile;
  }

  @override
  Future<NotificationPreferencesEntity> fetchNotificationPreferences() {
    return _localDataSource.getNotificationPreferences();
  }

  @override
  Future<void> setNotificationPreference(String key, bool value) {
    return _localDataSource.setNotificationPreference(key, value);
  }

  @override
  Future<bool> setPushEnabled(bool enabled) async {
    final resolved = await _deviceDataSource.setPushEnabled(enabled);
    await _localDataSource.setNotificationPreference(
      ProfileLocalDataSource.notifyPushKey,
      resolved,
    );
    return resolved;
  }

  @override
  Future<void> logout() async {
    await _deviceDataSource.unregisterCurrentDevice();
    await _localDataSource.setLoggedIn(false);
  }
}
