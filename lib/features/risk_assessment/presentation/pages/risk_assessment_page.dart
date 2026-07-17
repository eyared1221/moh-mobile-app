import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/global_notification_bell.dart';
import '../../../mentor/presentation/pages/mentor_page.dart';
import '../../../notifications/data/notification_automation_service.dart';
import '../../../auth/data/auth_session_storage.dart';
import '../../../auth/presentation/signin_screen.dart';
import '../../data/risk_assessment_repository.dart';
import '../../domain/entities/risk_question_entity.dart';
import '../../domain/usecases/get_risk_assessment_questions_use_case.dart';
import '../controllers/risk_assessment_page_controller.dart';
import '../widgets/risk_assessment_intro_page.dart';
import '../widgets/risk_assessment_question_page.dart';
import '../widgets/risk_assessment_result_page.dart';
import '../../../services/presentation/pages/clinic_page.dart';

class RiskAssessmentPage extends StatefulWidget {
  final String? age;
  final String? userName;

  const RiskAssessmentPage({
    super.key,
    this.age,
    this.userName,
  });

  @override
  State<RiskAssessmentPage> createState() => _RiskAssessmentPageState();
}

enum _RiskStage { intro, questions, result }

enum _RiskLevel { low, high }

class _RiskAssessmentPageState extends State<RiskAssessmentPage> {
  late final RiskAssessmentPageController _controller;

  List<RiskQuestionEntity> _questions = const [];
  List<int?> _selectedOptionIndexes = const [];
  bool _isLoadingQuestions = true;
  bool _isSavingAssessment = false;
  String? _saveAssessmentMessage;
  bool _saveAssessmentNeedsReauth = false;

  _RiskStage _stage = _RiskStage.intro;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = RiskAssessmentPageController(
      GetRiskAssessmentQuestionsUseCase(RiskAssessmentRepository()),
    );
    _bootstrapQuestions();
  }

  Future<void> _bootstrapQuestions() async {
    final cachedQuestions = await _controller.loadCachedQuestions();
    if (!mounted) return;

    if (cachedQuestions.isNotEmpty) {
      setState(() {
        _applyQuestions(cachedQuestions, preserveSelections: false);
      });
    }

    unawaited(
      _refreshQuestions(showLoading: cachedQuestions.isEmpty),
    );
  }

  Future<void> _refreshQuestions({bool showLoading = false}) async {
    try {
      if (mounted && showLoading) {
        setState(() {
          _isLoadingQuestions = true;
        });
      }

      final items = await _controller.loadQuestions();
      if (!mounted) return;

      setState(() {
        _applyQuestions(items, preserveSelections: true);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (_questions.isEmpty) {
          _questions = const [];
          _selectedOptionIndexes = const [];
        }
        _isLoadingQuestions = false;
      });
    }
  }

  Future<void> _syncQuestions() async {
    await _refreshQuestions(showLoading: _questions.isEmpty);
  }

  void _applyQuestions(
    List<RiskQuestionEntity> items, {
    required bool preserveSelections,
  }) {
    final previousSelections = <String, int?>{};
    if (preserveSelections) {
      for (var index = 0; index < _questions.length; index++) {
        previousSelections[_questions[index].id] = _selectedOptionIndexes[index];
      }
    }

    _questions = items;
    _selectedOptionIndexes = items
        .map((question) {
          final selectedIndex = previousSelections[question.id];
          if (selectedIndex == null) {
            return null;
          }
          return selectedIndex < question.options.length ? selectedIndex : null;
        })
        .toList();
    _currentIndex = items.isEmpty
        ? 0
        : _currentIndex.clamp(0, items.length - 1) as int;
    if (items.isEmpty && _stage == _RiskStage.questions) {
      _stage = _RiskStage.intro;
    }
    _isLoadingQuestions = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: isDark ? Colors.white : colorScheme.primary,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Risk Assessment'),
        actions: [
          GlobalTopBarActions(onSyncPressed: _syncQuestions),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _buildStageContent(colorScheme, textTheme),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStageContent(ColorScheme colorScheme, TextTheme textTheme) {
    switch (_stage) {
      case _RiskStage.intro:
        return RiskAssessmentIntroPage(
          key: const ValueKey('intro'),
          colorScheme: colorScheme,
          textTheme: textTheme,
          hasQuestions: _questions.isNotEmpty,
          onGetStarted: _startAssessment,
        );
      case _RiskStage.questions:
        if (_isLoadingQuestions) {
          return _buildLoadingState(
            colorScheme,
            textTheme,
            key: const ValueKey('loading'),
          );
        }
        if (_questions.isEmpty) {
          return _buildEmptyState(
            colorScheme,
            textTheme,
            key: const ValueKey('empty'),
          );
        }
        return RiskAssessmentQuestionPage(
          key: ValueKey('question-$_currentIndex'),
          question: _questions[_currentIndex],
          currentQuestion: _currentIndex + 1,
          totalQuestions: _questions.length,
          selectedIndex: _selectedOptionIndexes[_currentIndex],
          onSelectOption: _selectOption,
          colorScheme: colorScheme,
          textTheme: textTheme,
          isFirst: _currentIndex == 0,
          isAnswered: _selectedOptionIndexes[_currentIndex] != null,
          isLast: _currentIndex == _questions.length - 1,
          onPrevious: _currentIndex == 0 ? _backToIntro : _goPrevious,
          onNext: _goNext,
        );
      case _RiskStage.result:
        if (_questions.isEmpty) {
          return _buildEmptyState(
            colorScheme,
            textTheme,
            key: const ValueKey('empty'),
          );
        }
        return RiskAssessmentResultPage(
          key: const ValueKey('result'),
          isHigh: _riskLevel == _RiskLevel.high,
          statusLabel: _resultStatusLabel,
          actions: _resultActions,
          keyMessage: _resultKeyMessage,
          saveStatusMessage: _isSavingAssessment
              ? 'Saving this assessment to your history...'
              : _saveAssessmentMessage,
          saveStatusIsError: !_isSavingAssessment && _saveAssessmentMessage != null,
          saveStatusActionLabel:
              _saveAssessmentNeedsReauth ? 'Sign in again' : null,
          onSaveStatusAction:
              _saveAssessmentNeedsReauth ? _navigateToSignIn : null,
          colorScheme: colorScheme,
          textTheme: textTheme,
          onTalkToMentor: _openPeerMentor,
          onGetService: _openHealthService,
        );
    }
  }

  Widget _buildLoadingState(ColorScheme colorScheme, TextTheme textTheme, {Key? key}) {
    return Center(
      key: key,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme, {Key? key}) {
    return Center(
      key: key,
      child: Text(
        'No assessment questions available right now.',
        style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ) ??
            TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget? _buildBottomBar() {
    if (_stage == _RiskStage.questions) {
      return null;
    }

    return AppBottomNav(
      age: widget.age ?? '',
      currentIndex: -1,
      userName: widget.userName,
    );
  }

  void _selectOption(int index) {
    setState(() {
      _selectedOptionIndexes[_currentIndex] = index;
    });
  }

  void _startAssessment() {
    setState(() {
      _stage = _RiskStage.questions;
      _currentIndex = 0;
      _saveAssessmentMessage = null;
      _saveAssessmentNeedsReauth = false;
    });
  }

  void _backToIntro() {
    setState(() {
      _stage = _RiskStage.intro;
    });
  }

  void _goPrevious() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex -= 1;
      }
    });
  }

  void _goNext() {
    final isLast = _currentIndex == _questions.length - 1;
    setState(() {
      if (isLast) {
        _stage = _RiskStage.result;
        _isSavingAssessment = true;
        _saveAssessmentMessage = null;
        _saveAssessmentNeedsReauth = false;
      } else {
        _currentIndex += 1;
      }
    });

    if (isLast) {
      unawaited(_persistLatestAssessment());
      unawaited(
        NotificationAutomationService.instance.recordRiskAssessmentCompleted(
          riskLevel: _riskLevel.name,
        ),
      );
    }
  }

  void _openHealthService() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClinicPage(
          age: widget.age ?? '',
          userName: widget.userName,
        ),
      ),
    );
  }

  void _openPeerMentor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MentorPage(
          age: widget.age,
          userName: widget.userName,
        ),
      ),
    );
  }

  int _questionNumberAt(int index) {
    return _questions[index].number ?? (index + 1);
  }

  bool _isYesAnswerFor(int index) {
    final selectedIndex = _selectedOptionIndexes[index];
    if (selectedIndex == null) {
      return false;
    }

    final options = _questions[index].options;
    if (selectedIndex < 0 || selectedIndex >= options.length) {
      return false;
    }

    return options[selectedIndex].label.trim().toLowerCase() == 'yes';
  }

  int _yesCountInRange(int startInclusive, int endInclusive) {
    var count = 0;

    for (var i = 0; i < _questions.length; i += 1) {
      final questionNumber = _questionNumberAt(i);
      if (questionNumber < startInclusive || questionNumber > endInclusive) {
        continue;
      }

      if (_isYesAnswerFor(i)) {
        count += 1;
      }
    }

    return count;
  }

  int get _totalYesCount {
    var count = 0;

    for (var i = 0; i < _questions.length; i += 1) {
      if (_isYesAnswerFor(i)) {
        count += 1;
      }
    }

    return count;
  }

  _RiskLevel get _riskLevel {
    final hasYesInQuestionsOneToSix = _yesCountInRange(1, 6) >= 1;
    final hasThreeYesInQuestionsSevenToEleven = _yesCountInRange(7, 11) >= 3;

    return hasYesInQuestionsOneToSix || hasThreeYesInQuestionsSevenToEleven
        ? _RiskLevel.high
        : _RiskLevel.low;
  }

  String get _resultStatusLabel {
    return _riskLevel == _RiskLevel.high
        ? 'Higher Risk for HIV Infection'
        : 'Low HIV Risk';
  }

  List<String> get _resultActions {
    return _riskLevel == _RiskLevel.high ? _highRiskActions : _lowRiskActions;
  }

  String get _resultKeyMessage {
    return _riskLevel == _RiskLevel.high
        ? _highRiskKeyMessage
        : _lowRiskKeyMessage;
  }

  Future<void> _persistLatestAssessment() async {
    try {
      await _controller.submitLatestResult(
        riskLevel: _riskLevel.name,
        resultLabel: _resultStatusLabel,
        riskScore: _totalYesCount,
        takenAt: DateTime.now(),
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _isSavingAssessment = false;
        _saveAssessmentMessage = null;
        _saveAssessmentNeedsReauth = false;
      });
    } catch (e) {
      final needsReauth = _isAuthenticationFailure(e);
      final message = needsReauth
          ? 'Your session expired before we could save this assessment. Sign in again to keep your history up to date.'
          : 'We could not save this assessment to your history right now. Please try again in a moment.';

      if (!mounted) {
        return;
      }

      setState(() {
        _isSavingAssessment = false;
        _saveAssessmentMessage = message;
        _saveAssessmentNeedsReauth = needsReauth;
      });

      debugPrint('Failed to save risk assessment: $e');
    }
  }

  bool _isAuthenticationFailure(Object error) {
    final normalizedMessage = error.toString().toLowerCase();
    return normalizedMessage.contains('sign in again') ||
        normalizedMessage.contains('authentication required') ||
        normalizedMessage.contains('invalid or expired token') ||
        normalizedMessage.contains('unauthorized');
  }

  Future<void> _navigateToSignIn() async {
    await AuthSessionStorage.clear();
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SignInScreen(),
      ),
    );
  }
}

const List<String> _highRiskActions = [
  'Get tested for HIV immediately.',
  'Use condoms consistently and correctly.',
  'Actively participate in all peer learning sessions.',
];

const List<String> _lowRiskActions = [
  'Practice abstinence or mutual faithfulness and use condoms consistently and correctly.',
  'Actively participate in all peer learning sessions.',
];

const String _highRiskKeyMessage =
    'Having a high-risk score does not mean that you are infected with HIV. '
    'However, if risky behaviors continue, there is a possibility of acquiring HIV infection. '
    'Therefore, make strong efforts to reduce your level of HIV exposure risk.';

const String _lowRiskKeyMessage =
    'Having a low-risk score indicates a lower current risk of HIV exposure, but it does not guarantee you not to be at risk if you engage in risky behavior. Continuing to avoid behaviors that increase HIV risk will help you maintain this low-risk status in the future.';
