import '../../data/datasources/risk_assessment_local_data_source.dart';
import '../../data/datasources/risk_assessment_remote_data_source.dart';
import '../../domain/entities/risk_question_entity.dart';
import '../../domain/usecases/get_risk_assessment_questions_use_case.dart';

enum RiskAssessmentSaveMode {
  syncedToAccount,
  savedAnonymousToDatabase,
  savedLocallyPendingSync,
}

class RiskAssessmentSaveResult {
  const RiskAssessmentSaveResult(this.mode, {this.needsReauth = false});

  final RiskAssessmentSaveMode mode;
  final bool needsReauth;
}

class RiskAssessmentPageController {
  RiskAssessmentPageController(
    this._getQuestionsUseCase, {
    RiskAssessmentLocalDataSource? localDataSource,
    RiskAssessmentRemoteDataSource? remoteDataSource,
  }) : _localDataSource = localDataSource ?? RiskAssessmentLocalDataSource(),
       _remoteDataSource =
           remoteDataSource ?? RiskAssessmentRemoteDataSource();

  final GetRiskAssessmentQuestionsUseCase _getQuestionsUseCase;
  final RiskAssessmentLocalDataSource _localDataSource;
  final RiskAssessmentRemoteDataSource _remoteDataSource;

  Future<List<RiskQuestionEntity>> loadQuestions() {
    return _getQuestionsUseCase();
  }

  Future<List<RiskQuestionEntity>> loadCachedQuestions() async {
    final cachedPayload = await _localDataSource.getCachedQuestionsPayload();
    if (cachedPayload == null) {
      return const <RiskQuestionEntity>[];
    }

    try {
      return _remoteDataSource.mapPayloadToQuestions(cachedPayload);
    } catch (_) {
      return const <RiskQuestionEntity>[];
    }
  }

  Future<RiskAssessmentSaveResult> submitLatestResult({
    required String riskLevel,
    required String resultLabel,
    required int riskScore,
    required DateTime takenAt,
  }) async {
    final hasAuthenticatedSession =
        await _localDataSource.hasAuthenticatedSession();
    if (!hasAuthenticatedSession) {
      var credentials =
          await _localDataSource.getAnonymousProfileCredentials();
      credentials ??= await _remoteDataSource.createAnonymousProfile();
      await _localDataSource.saveAnonymousProfileCredentials(credentials);
      await _remoteDataSource.submitAnonymousResult(
        credentials: credentials,
        riskLevel: riskLevel,
        resultLabel: resultLabel,
        riskScore: riskScore,
        takenAt: takenAt,
      );
      return const RiskAssessmentSaveResult(
        RiskAssessmentSaveMode.savedAnonymousToDatabase,
      );
    }

    try {
      await _remoteDataSource.submitLatestResult(
        riskLevel: riskLevel,
        resultLabel: resultLabel,
        riskScore: riskScore,
        takenAt: takenAt,
      );
      await _localDataSource.saveAssessmentResult(
        riskLevel: riskLevel,
        resultLabel: resultLabel,
        riskScore: riskScore,
        takenAt: takenAt,
        storageMode: 'account',
        syncedToAccount: true,
      );
      return const RiskAssessmentSaveResult(
        RiskAssessmentSaveMode.syncedToAccount,
      );
    } catch (error) {
      final needsReauth = _isAuthenticationFailure(error);
      if (needsReauth) {
        try {
          var credentials =
              await _localDataSource.getAnonymousProfileCredentials();
          credentials ??= await _remoteDataSource.createAnonymousProfile();
          await _localDataSource.saveAnonymousProfileCredentials(credentials);
          await _remoteDataSource.submitAnonymousResult(
            credentials: credentials,
            riskLevel: riskLevel,
            resultLabel: resultLabel,
            riskScore: riskScore,
            takenAt: takenAt,
          );
          await _localDataSource.saveAssessmentResult(
            riskLevel: riskLevel,
            resultLabel: resultLabel,
            riskScore: riskScore,
            takenAt: takenAt,
            storageMode: 'anonymous_database_after_reauth_failure',
            syncedToAccount: false,
          );
          return const RiskAssessmentSaveResult(
            RiskAssessmentSaveMode.savedAnonymousToDatabase,
            needsReauth: true,
          );
        } catch (_) {}
      }

      await _localDataSource.saveAssessmentResult(
        riskLevel: riskLevel,
        resultLabel: resultLabel,
        riskScore: riskScore,
        takenAt: takenAt,
        storageMode: needsReauth ? 'device_pending_sign_in' : 'device_pending_sync',
        syncedToAccount: false,
      );
      return RiskAssessmentSaveResult(
        RiskAssessmentSaveMode.savedLocallyPendingSync,
        needsReauth: needsReauth,
      );
    }
  }

  bool _isAuthenticationFailure(Object error) {
    final normalizedMessage = error.toString().toLowerCase();
    return normalizedMessage.contains('sign in again') ||
        normalizedMessage.contains('authentication required') ||
        normalizedMessage.contains('invalid or expired token') ||
        normalizedMessage.contains('unauthorized');
  }
}
