import '../../models/mentor.dart';
import '../mentor_api_client.dart';

class MentorRemoteDataSource {
  MentorRemoteDataSource({MentorApiClient? apiClient})
      : _apiClient = apiClient ?? MentorApiClient();

  final MentorApiClient _apiClient;

  Future<Map<String, dynamic>> fetchMentorPayload() {
    return _apiClient.get('/');
  }

  List<MentorModel> mapPayloadToMentors(Map<String, dynamic> payload) {
    final mentorsJson = _extractMentorList(payload);

    return mentorsJson
        .map(_asStringDynamicMap)
        .map(MentorModel.fromJson)
        .where((mentor) => mentor.id.isNotEmpty)
        .toList();
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
