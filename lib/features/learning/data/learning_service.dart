import 'repositories/learning_repository_impl.dart';

class LearningService extends LearningRepositoryImpl {
  LearningService({
    super.remoteDataSource,
    super.localDataSource,
  });

  static final LearningService instance = LearningService();
}
