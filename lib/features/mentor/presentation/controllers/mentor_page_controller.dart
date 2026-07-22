import '../../data/datasources/mentor_local_data_source.dart';
import '../../data/datasources/mentor_remote_data_source.dart';
import '../../domain/entities/mentor_entity.dart';
import '../../domain/usecases/get_mentors_use_case.dart';

class MentorPageController {
  MentorPageController(
    this._getMentorsUseCase, {
    MentorLocalDataSource? localDataSource,
    MentorRemoteDataSource? remoteDataSource,
  }) : _localDataSource = localDataSource ?? MentorLocalDataSource(),
       _remoteDataSource = remoteDataSource ?? MentorRemoteDataSource();

  final GetMentorsUseCase _getMentorsUseCase;
  final MentorLocalDataSource _localDataSource;
  final MentorRemoteDataSource _remoteDataSource;

  Future<List<MentorEntity>> loadMentors() {
    return _getMentorsUseCase();
  }

  Future<List<MentorEntity>> loadCachedMentors() async {
    final cachedPayload = await _localDataSource.getCachedMentorPayload();
    if (cachedPayload == null) {
      return const <MentorEntity>[];
    }

    try {
      return _remoteDataSource.mapPayloadToMentors(cachedPayload);
    } catch (_) {
      return const <MentorEntity>[];
    }
  }

  List<MentorEntity> filterMentors(List<MentorEntity> mentors, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return mentors;
    }

    return mentors.where((mentor) {
      final name = mentor.fullName.toLowerCase();
      final phone = mentor.phone.toLowerCase();
      final assignedArea = mentor.assignedArea?.toLowerCase() ?? '';
      return name.contains(normalized) ||
          phone.contains(normalized) ||
          assignedArea.contains(normalized);
    }).toList();
  }
}
