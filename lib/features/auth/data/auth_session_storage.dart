import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/login_result_entity.dart';
import '../../profile/data/datasources/profile_local_data_source.dart';

class AuthSessionStorage {
  static const String _tokenKey = 'authToken';
  static const String _emailKey = 'userEmail';
  static const String _phoneKey = 'userPhone';
  static const String _identifierKey = 'userId';
  static const String _userIdKey = 'userId';

  Future<void> saveLogin(LoginResultEntity result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('authToken', result.token);
    await prefs.setString('userId', result.user.id);
    await prefs.setString('userEmail', result.user.email);
    await prefs.setString('userPhone', result.user.phone ?? '');
    await prefs.setString('userName', result.user.username);
    await prefs.setString('userAge', result.user.ageGroup);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_identifierKey);
    await prefs.remove(_userIdKey);
    await prefs.remove('userName');
    await prefs.remove('userAge');
    await prefs.remove(ProfileLocalDataSource.nameKey);
    await prefs.remove(ProfileLocalDataSource.ageKey);
    await prefs.remove(ProfileLocalDataSource.emailKey);
    await prefs.remove(ProfileLocalDataSource.phoneKey);
    await prefs.remove(ProfileLocalDataSource.avatarPathKey);
  }

  static Future<String?> getIdentifier() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_identifierKey);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey)?.trim() ?? '';
    if (email.isNotEmpty) {
      return email;
    }

    final profileEmail = prefs.getString(ProfileLocalDataSource.emailKey)?.trim() ?? '';
    return profileEmail.isNotEmpty ? profileEmail : null;
  }

  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString(_phoneKey)?.trim() ?? '';
    if (phone.isNotEmpty) {
      return phone;
    }

    final profilePhone = prefs.getString(ProfileLocalDataSource.phoneKey)?.trim() ?? '';
    return profilePhone.isNotEmpty ? profilePhone : null;
  }

  static Future<String?> getLoginContact() async {
    final email = (await getEmail())?.trim() ?? '';
    if (email.isNotEmpty) {
      return email;
    }

    final phone = (await getPhone())?.trim() ?? '';
    return phone.isNotEmpty ? phone : null;
  }
}
