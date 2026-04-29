import '../../models/profile_user.dart';
import '../profile_api_client.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource({ProfileApiClient? apiClient})
      : _apiClient = apiClient ?? ProfileApiClient();

  final ProfileApiClient _apiClient;

  Future<Map<String, dynamic>> fetchProfilePayload() {
    return _apiClient.get('/profile');
  }

  Future<Map<String, dynamic>> saveProfilePayload(ProfileUser user) {
    return _apiClient.put('/profile', profileToBackendJson(user));
  }

  ProfileUser profileFromBackendJson(
    Map<String, dynamic> json, {
    required int fallbackAge,
    String? fallbackName,
  }) {
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
}
