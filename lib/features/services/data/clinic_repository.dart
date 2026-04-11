import '../models/clinic.dart';
import 'clinic_api_client.dart';

class ClinicRepository {
  ClinicRepository({ClinicApiClient? apiClient})
      : _apiClient = apiClient ?? ClinicApiClient();

  final ClinicApiClient _apiClient;

  static const LatLng _fallbackLocation = LatLng(9.0054, 38.7636);

  Future<List<Clinic>> fetchClinics() async {
    try {
      final payload = await _apiClient.get('/');
      final facilitiesJson = _extractFacilityList(payload);

      return facilitiesJson
          .map(_asStringDynamicMap)
          .map(_mapFacilityToClinic)
          .where((clinic) => clinic.id.isNotEmpty)
          .toList();
    } catch (e) {
      throw ClinicRepositoryException('Failed to load clinics: $e');
    }
  }

  Clinic _mapFacilityToClinic(Map<String, dynamic> json) {
    final id = _readString(json['id']) ?? _readString(json['_id']) ?? '';
    final name = _readString(json['facilityName']) ?? _readString(json['name']) ?? 'Clinic';
    final address = _buildAddress(json);
    final phone = _readString(json['phone']) ?? 'Phone not available';
    final email = _readString(json['email']);
    final website = _readString(json['website']);
    final hours = _readString(json['hours']) ??
        _readString(json['workingHours']) ??
        _hoursFromOperationalStatus(_readString(json['operationalStatus'])) ??
        'Hours not available';
    final description = _readString(json['description']) ?? _buildDescription(json);
    final services = _buildServices(json);
    final location = _parseLatitudeLongitude(_readString(json['latitudeLongitude'])) ?? _fallbackLocation;
    final imageUrl = _extractImageUrl(json);
    final altitude = _readString(json['altitude']);

    return Clinic(
      id: id,
      name: name,
      address: address,
      phone: phone,
      email: email,
      website: website,
      hours: hours,
      description: description,
      services: services,
      location: location,
      imageUrl: imageUrl,
      altitude: altitude,
    );
  }
}

List<dynamic> _extractFacilityList(Map<String, dynamic> payload) {
  final data = payload['data'];
  if (data is List<dynamic>) {
    return data;
  }

  if (data is Map) {
    return [data];
  }

  final facilities = payload['facilities'];
  if (facilities is List<dynamic>) {
    return facilities;
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

String _buildAddress(Map<String, dynamic> json) {
  final specificAreaName = _readString(json['specificAreaName']);
  final kebele = _readString(json['kebele']);
  final city = _readString(json['city']);
  final zone = _readString(json['zoneSubcity']) ?? _readString(json['zoneSubCity']);
  final region = _readString(json['region']);
  final fallback = _readString(json['address']) ?? 'Address not available';

  final parts = [specificAreaName, kebele, city, zone, region]
      .whereType<String>()
      .where((item) => item.isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return fallback;
  }

  return parts.join(', ');
}

String? _hoursFromOperationalStatus(String? operationalStatus) {
  if (operationalStatus == null) return null;
  return operationalStatus == 'Operational' ? 'Open (Operational)' : operationalStatus;
}

String _buildDescription(Map<String, dynamic> json) {
  final facilityType = _readString(json['facilityType']);
  final facilitySubType = _readString(json['facilitySubType']);
  final ownership = _readString(json['ownership']);
  final status = _readString(json['operationalStatus']) ?? _readString(json['status']);

  final parts = [facilityType, facilitySubType, ownership]
      .whereType<String>()
      .where((item) => item.isNotEmpty)
      .toList();

  if (parts.isEmpty && status != null) {
    return 'Service status: $status.';
  }

  final prefix = parts.isEmpty ? 'Healthcare facility' : parts.join(' - ');
  final suffix = status == null ? '' : ' Status: $status.';
  return '$prefix.$suffix'.trim();
}

List<String> _buildServices(Map<String, dynamic> json) {
  final values = <String>{
    if (_readString(json['facilityType']) != null) _readString(json['facilityType'])!,
    if (_readString(json['facilitySubType']) != null) _readString(json['facilitySubType'])!,
    if (_readString(json['primaryHealthCareUnit']) != null) _readString(json['primaryHealthCareUnit'])!,
    if (_readString(json['referralLinkage']) != null) _readString(json['referralLinkage'])!,
  };

  if (values.isNotEmpty) {
    return values.toList();
  }

  return const ['General Care'];
}

LatLng? _parseLatitudeLongitude(String? raw) {
  if (raw == null) return null;
  final normalized = raw.trim();
  if (normalized.isEmpty) return null;

  final matches = RegExp(r'-?\d+(\.\d+)?').allMatches(normalized).toList();
  if (matches.length < 2) return null;

  final lat = double.tryParse(matches[0].group(0)!);
  final lon = double.tryParse(matches[1].group(0)!);

  if (lat == null || lon == null) return null;
  return LatLng(lat, lon);
}

String? _extractImageUrl(Map<String, dynamic> json) {
  final imageUrls = json['imageUrls'];
  if (imageUrls is List) {
    for (final image in imageUrls) {
      final value = _readString(image);
      if (value != null) return value;
    }
  }

  return _readString(json['imageUrl']);
}

class ClinicRepositoryException implements Exception {
  const ClinicRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'ClinicRepositoryException: $message';
}
