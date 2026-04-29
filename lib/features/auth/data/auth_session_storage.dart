import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/login_result_entity.dart';

class AuthSessionStorage {
  Future<void> saveLogin(LoginResultEntity result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('authToken', result.token);
    await prefs.setString('userId', result.user.id);
    await prefs.setString('userEmail', result.user.email);
    await prefs.setString('userName', result.user.username);
    await prefs.setString('userAge', result.user.ageGroup);
  }
}
