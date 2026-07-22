import '../../data/repositories/campus_repository_impl.dart';
import '../../models/clinic.dart' show Clinic, LatLng;
import '../../models/university_campus_mapping.dart';
import '../entities/campus_entity.dart';
import '../entities/lat_lng_entity.dart';
import '../repositories/campus_repository.dart';

/// GetCampusesUseCase focuses purely on business logic:
/// - Get campuses (from repository)
/// - Group campuses into sections
/// - Calculate derived coordinates from facilities
/// - Return clean result
class GetCampusesUseCase {
  GetCampusesUseCase({
    CampusRepository? repository,
  }) : _repository = repository ?? CampusRepositoryImpl();

  final CampusRepository _repository;

  static const _sectionGroups = {
    'Government Universities': 'Public University',
    'Private Universities in Addis Ababa': 'Addis Ababa Private',
    'Private Universities in Regional Towns': 'Regional Private',
  };

  static const LatLng _fallbackLocation = LatLng(9.0054, 38.7636);

  Future<GetCampusesResult> call() async {
    // Get raw data from repository (handles caching/API)
    final mappings = await _repository.fetchUniversityMappings();
    final clinics = await _repository.fetchClinics();

    // Business logic: group and calculate
    final sections = _groupIntoSections(mappings, clinics);

    return GetCampusesResult(sections: sections);
  }

  List<CampusSectionEntity> _groupIntoSections(
    List<UniversityCampusMapping> mappings,
    List<Clinic> clinics,
  ) {
    final grouped = <String, List<CampusEntity>>{};
    for (final entry in _sectionGroups.entries) {
      grouped[entry.key] = [];
    }

    for (final mapping in mappings) {
      final sectionTitle = _sectionGroups.entries
          .firstWhere(
            (entry) => entry.value == mapping.group,
            orElse: () => const MapEntry('', ''),
          )
          .key;

      if (sectionTitle.isEmpty) continue;

      final location = _calculateAverageCoordinates(mapping.recommendedFacilities, clinics);

      grouped[sectionTitle]!.add(CampusEntity(
        id: mapping.id,
        title: mapping.displayTitle,
        university: mapping.university,
        subtitle: mapping.displaySubtitle,
        location: location,
      ));
    }

    return _sectionGroups.keys.map((title) {
      final campuses = grouped[title]!;
      campuses.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      return CampusSectionEntity(title: title, campuses: campuses);
    }).toList();
  }

  LatLngEntity? _calculateAverageCoordinates(
    List<UniversityRecommendedFacility> facilities,
    List<Clinic> clinics,
  ) {
    if (facilities.isEmpty || clinics.isEmpty) return null;

    final clinicsById = <String, Clinic>{};
    final clinicsByName = <String, Clinic>{};
    for (final clinic in clinics) {
      final normalizedClinicId = clinic.id.trim().toLowerCase();
      if (normalizedClinicId.isNotEmpty) {
        clinicsById[normalizedClinicId] = clinic;
      }

      final normalizedClinicName = normalizeCampusLookupKey(clinic.name);
      if (normalizedClinicName.isNotEmpty) {
        clinicsByName[normalizedClinicName] = clinic;
      }
    }

    final latitudes = <double>[];
    final longitudes = <double>[];

    for (final facility in facilities) {
      final normalizedFacilityId = facility.facilityId.trim().toLowerCase();
      final normalizedFacilityName = normalizeCampusLookupKey(facility.name);

      final clinic = normalizedFacilityId.isNotEmpty
          ? clinicsById[normalizedFacilityId]
          : null;
      final matchedClinic = clinic ?? clinicsByName[normalizedFacilityName];

      if (matchedClinic == null) continue;

      final loc = matchedClinic.location;
      if (loc.latitude != _fallbackLocation.latitude ||
          loc.longitude != _fallbackLocation.longitude) {
        latitudes.add(loc.latitude);
        longitudes.add(loc.longitude);
      }
    }

    if (latitudes.isEmpty) return null;

    return LatLngEntity(
      latitudes.reduce((a, b) => a + b) / latitudes.length,
      longitudes.reduce((a, b) => a + b) / longitudes.length,
    );
  }
}

class GetCampusesResult {
  const GetCampusesResult({
    required this.sections,
  });

  final List<CampusSectionEntity> sections;
}
