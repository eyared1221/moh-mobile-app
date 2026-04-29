import '../../domain/entities/clinic_entity.dart';
import '../../domain/repositories/clinic_repository.dart';
import '../datasources/clinic_local_data_source.dart';
import '../datasources/clinic_remote_data_source.dart';

class ClinicRepositoryImpl implements ClinicRepository {
  ClinicRepositoryImpl({
    ClinicRemoteDataSource? remoteDataSource,
    ClinicLocalDataSource? localDataSource,
  }) : _remoteDataSource = remoteDataSource ?? ClinicRemoteDataSource(),
       _localDataSource = localDataSource ?? ClinicLocalDataSource();

  final ClinicRemoteDataSource _remoteDataSource;
  final ClinicLocalDataSource _localDataSource;

  @override
  Future<List<ClinicEntity>> fetchClinics() async {
    try {
      final payload = await _remoteDataSource.fetchClinicsPayload();
      await _localDataSource.cacheClinicsPayload(payload);
      return _remoteDataSource.mapPayloadToClinics(payload);
    } catch (e) {
      final cachedPayload = await _localDataSource.getCachedClinicsPayload();
      if (cachedPayload != null) {
        return _remoteDataSource.mapPayloadToClinics(cachedPayload);
      }
      throw ClinicRepositoryException('Failed to load clinics: $e');
    }
  }
}

class ClinicRepositoryException implements Exception {
  const ClinicRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'ClinicRepositoryException: $message';
}
