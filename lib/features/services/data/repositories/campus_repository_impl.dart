import '../../data/datasources/clinic_local_data_source.dart';
import '../../data/datasources/clinic_remote_data_source.dart';
import '../../data/datasources/university_mapping_local_data_source.dart';
import '../../data/datasources/university_mapping_remote_data_source.dart';
import '../../domain/repositories/campus_repository.dart';
import '../../models/clinic.dart';
import '../../models/university_campus_mapping.dart';

class CampusRepositoryImpl implements CampusRepository {
  CampusRepositoryImpl({
    UniversityMappingRemoteDataSource? universityRemote,
    UniversityMappingLocalDataSource? universityLocal,
    ClinicRemoteDataSource? clinicRemote,
    ClinicLocalDataSource? clinicLocal,
  })  : _universityRemote = universityRemote ?? UniversityMappingRemoteDataSource(),
        _universityLocal = universityLocal ?? UniversityMappingLocalDataSource(),
        _clinicRemote = clinicRemote ?? ClinicRemoteDataSource(),
        _clinicLocal = clinicLocal ?? ClinicLocalDataSource();

  final UniversityMappingRemoteDataSource _universityRemote;
  final UniversityMappingLocalDataSource _universityLocal;
  final ClinicRemoteDataSource _clinicRemote;
  final ClinicLocalDataSource _clinicLocal;

  @override
  Future<List<UniversityCampusMapping>> fetchUniversityMappings() async {
    // Try cache first
    final cachedPayload = await _universityLocal.getCachedUniversityMappingsPayload();
    if (cachedPayload != null) {
      try {
        final cached = _universityRemote.mapPayloadToMappings(cachedPayload);
        if (cached.isNotEmpty) {
          // Refresh in background
          _refreshMappingsInBackground();
          return cached;
        }
      } catch (_) {
        // Cache corrupted, fetch fresh
      }
    }

    // Fetch from backend
    try {
      final mappings = await _universityRemote.fetchUniversityMappings();
      return mappings;
    } catch (e) {
      throw CampusRepositoryException('Failed to fetch university mappings: $e');
    }
  }

  Future<void> _refreshMappingsInBackground() async {
    try {
      await _universityRemote.fetchUniversityMappings();
      // Cache updated by remote data source
    } catch (_) {
      // Ignore background refresh errors
    }
  }

  @override
  Future<List<Clinic>> fetchClinics() async {
    // Try cache first
    final cachedPayload = await _clinicLocal.getCachedClinicsPayload();
    if (cachedPayload != null) {
      try {
        final cached = _clinicRemote.mapPayloadToClinics(cachedPayload);
        if (cached.isNotEmpty) {
          // Refresh in background
          _refreshClinicsInBackground();
          return cached;
        }
      } catch (_) {
        // Cache corrupted, fetch fresh
      }
    }

    // Fetch from backend
    try {
      final payload = await _clinicRemote.fetchClinicsPayload();
      await _clinicLocal.cacheClinicsPayload(payload);
      return _clinicRemote.mapPayloadToClinics(payload);
    } catch (e) {
      throw CampusRepositoryException('Failed to fetch clinics: $e');
    }
  }

  Future<void> _refreshClinicsInBackground() async {
    try {
      final payload = await _clinicRemote.fetchClinicsPayload();
      await _clinicLocal.cacheClinicsPayload(payload);
    } catch (_) {
      // Ignore background refresh errors
    }
  }
}

class CampusRepositoryException implements Exception {
  const CampusRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'CampusRepositoryException: $message';
}
