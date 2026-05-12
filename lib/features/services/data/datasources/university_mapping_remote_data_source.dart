import '../../models/university_campus_mapping.dart';
import '../university_mapping_api_client.dart';
import 'university_mapping_local_data_source.dart';

class UniversityMappingRemoteDataSource {
  UniversityMappingRemoteDataSource({
    UniversityMappingApiClient? apiClient,
    UniversityMappingLocalDataSource? localDataSource,
  }) : _apiClient = apiClient ?? UniversityMappingApiClient(),
       _localDataSource = localDataSource ?? UniversityMappingLocalDataSource();

  final UniversityMappingApiClient _apiClient;
  final UniversityMappingLocalDataSource _localDataSource;

  Future<List<UniversityCampusMapping>> fetchUniversityMappings() async {
    final payload = await _apiClient.get('/');
    await _localDataSource.cacheUniversityMappingsPayload(payload);
    final mappingsJson = _extractUniversityMappings(payload);

    return mappingsJson
        .map(_asStringDynamicMap)
        .map(_mapUniversityMapping)
        .where((mapping) => mapping.university.isNotEmpty)
        .toList();
  }

  List<UniversityCampusMapping> mapPayloadToMappings(Map<String, dynamic> payload) {
    final mappingsJson = _extractUniversityMappings(payload);

    return mappingsJson
        .map(_asStringDynamicMap)
        .map(_mapUniversityMapping)
        .where((mapping) => mapping.university.isNotEmpty)
        .toList();
  }

  UniversityCampusMapping _mapUniversityMapping(Map<String, dynamic> json) {
    final university = _readString(json['university']) ?? '';
    final campusPresentation = presentUniversityCampus(university);

    return UniversityCampusMapping(
      id: _readString(json['id']) ?? _readString(json['_id']) ?? '',
      university: university,
      group: _readString(json['group']) ?? '',
      recommendedFacilities: _mapRecommendedFacilities(
        json['recommendedFacilities'],
      ),
      status: _readString(json['status']) ?? '',
      displayTitle: campusPresentation.title,
      displaySubtitle: campusPresentation.subtitle,
    );
  }
}

List<UniversityRecommendedFacility> _mapRecommendedFacilities(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map(_asStringDynamicMap)
      .map(
        (item) => UniversityRecommendedFacility(
          facilityId: _readString(item['facilityId']) ?? '',
          name: _readString(item['name']) ?? '',
          facilityType: _readString(item['facilityType']) ?? '',
        ),
      )
      .where((item) => item.name.isNotEmpty)
      .toList();
}

List<dynamic> _extractUniversityMappings(Map<String, dynamic> payload) {
  final data = payload['data'];
  if (data is List<dynamic>) {
    return data;
  }

  if (data is Map) {
    return [data];
  }

  if (payload.containsKey('id') || payload.containsKey('_id')) {
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

String? _readString(dynamic value) {
  if (value == null) return null;
  final stringValue = '$value'.trim();
  return stringValue.isEmpty ? null : stringValue;
}
