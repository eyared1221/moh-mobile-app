import '../../domain/entities/mentor_entity.dart';
import '../../domain/repositories/mentor_repository.dart';
import '../datasources/mentor_local_data_source.dart';
import '../datasources/mentor_remote_data_source.dart';

class MentorRepositoryImpl implements MentorRepository {
  MentorRepositoryImpl({
    MentorRemoteDataSource? remoteDataSource,
    MentorLocalDataSource? localDataSource,
  }) : _remoteDataSource = remoteDataSource ?? MentorRemoteDataSource(),
       _localDataSource = localDataSource ?? MentorLocalDataSource();

  final MentorRemoteDataSource _remoteDataSource;
  final MentorLocalDataSource _localDataSource;

  @override
  Future<List<MentorEntity>> fetchMentors() async {
    try {
      final payload = await _remoteDataSource.fetchMentorPayload();
      await _localDataSource.cacheMentorPayload(payload);
      return _remoteDataSource.mapPayloadToMentors(payload);
    } catch (e) {
      final cachedPayload = await _localDataSource.getCachedMentorPayload();
      if (cachedPayload != null) {
        return _remoteDataSource.mapPayloadToMentors(cachedPayload);
      }
      throw MentorRepositoryException('Failed to load mentors: $e');
    }
  }
}

class MentorRepositoryException implements Exception {
  const MentorRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'MentorRepositoryException: $message';
}
