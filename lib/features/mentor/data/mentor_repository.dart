import 'mentor_api_client.dart';
import '../models/mentor.dart';

class MentorRepository {
  MentorRepository({MentorApiClient? apiClient})
      : _apiClient = apiClient ?? MentorApiClient();

  final MentorApiClient _apiClient;

  Future<List<Mentor>> fetchMentors() async {
    try {
      final payload = await _apiClient.get('/');
      final mentorsJson = _extractMentorList(payload);

      return mentorsJson
          .map(_asStringDynamicMap)
          .map(Mentor.fromJson)
          .where((mentor) => mentor.id.isNotEmpty)
          .toList();
    } catch (e) {
      throw MentorRepositoryException('Failed to load mentors: $e');
    }
  }
}

List<dynamic> _extractMentorList(Map<String, dynamic> payload) {
  final data = payload['data'];
  if (data is List<dynamic>) {
    return data;
  }

  if (data is Map) {
    return [data];
  }

  final mentors = payload['mentors'];
  if (mentors is List<dynamic>) {
    return mentors;
  }

  if (payload.containsKey('id')) {
    return [payload];
  }

  return const [];
}

Map<String, dynamic> _asStringDynamicMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.map((key, item) => MapEntry('$key', item));
  }

  return const <String, dynamic>{};
}

class MentorRepositoryException implements Exception {
  const MentorRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'MentorRepositoryException: $message';
}
