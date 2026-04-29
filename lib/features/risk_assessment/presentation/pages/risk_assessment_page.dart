import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/notification_badge.dart';
import '../../../notifications/data/app_notification_service.dart';
import '../../../notifications/data/notification_provider.dart';
import '../../../notifications/presentation/pages/notification_center_page.dart';
import '../../../mentor/presentation/pages/mentor_page.dart';
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

  _RiskStage _stage = _RiskStage.intro;
  int _currentIndex = 0;
  final AppNotificationService _notificationService = AppNotificationService.instance;
  final NotificationProvider _provider = NotificationProvider();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = RiskAssessmentPageController(
      GetRiskAssessmentQuestionsUseCase(RiskAssessmentRepository()),
    );
    _loadQuestions();
    _unreadCount = _provider.unreadCount;
    _loadUnreadCount();
    _provider.addListener(_onNotificationCountChanged);
  }

  @override
  void dispose() {
    _provider.removeListener(_onNotificationCountChanged);
    super.dispose();
  }

  void _onNotificationCountChanged() {
    if (mounted) {
      setState(() {
        _unreadCount = _provider.unreadCount;
      });
    }
  }

  Future<void> _loadQuestions() async {
    try {
      final items = await _controller.loadQuestions();
      if (!mounted) return;
      setState(() {
        _questions = items;
        _selectedOptionIndexes = List<int?>.filled(items.length, null);
        _isLoadingQuestions = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _questions = const [];
        _selectedOptionIndexes = const [];
        _isLoadingQuestions = false;
      });
    }
  }

  Future<void> _loadUnreadCount() async {
    await _notificationService.getUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: colorScheme.primary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Risk Assessment',
          style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ) ??
              TextStyle(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ),
        ),
        actions: [
          NotificationBadge(
            count: _unreadCount,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationCenterPage(),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_none),
              color: colorScheme.primary,
              tooltip: 'Notifications',
            ),
          ),
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
      bottomNavigationBar: _buildBottomBar(colorScheme),
    );
  }

  Widget _buildStageContent(ColorScheme colorScheme, TextTheme textTheme) {
    if (_isLoadingQuestions) {
      return _buildLoadingState(colorScheme, textTheme, key: const ValueKey('loading'));
    }

    if (_questions.isEmpty) {
      return _buildEmptyState(colorScheme, textTheme, key: const ValueKey('empty'));
    }

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
        return RiskAssessmentResultPage(
          key: const ValueKey('result'),
          isHigh: _riskLevel == _RiskLevel.high,
          statusLabel: _resultStatusLabel,
          actions: _resultActions,
          keyMessage: _resultKeyMessage,
          colorScheme: colorScheme,
          textTheme: textTheme,
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
            const SizedBox(width: 12),
            Text(
              'Preparing questions...',
              style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ) ??
                  TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
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

  Widget? _buildBottomBar(ColorScheme colorScheme) {
    if (_stage == _RiskStage.questions) {
      return null;
    }

    if (_stage == _RiskStage.intro) {
      return AppBottomNav(
        age: widget.age ?? '',
        currentIndex: -1,
        userName: widget.userName,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: _buildBottomActions(colorScheme),
        ),
        AppBottomNav(
          age: widget.age ?? '',
          currentIndex: -1,
          userName: widget.userName,
        ),
      ],
    );
  }

  Widget _buildBottomActions(ColorScheme colorScheme) {
    switch (_stage) {
      case _RiskStage.intro:
        return const SizedBox.shrink();
      case _RiskStage.questions:
        final isFirst = _currentIndex == 0;
        final isAnswered = _selectedOptionIndexes[_currentIndex] != null;
        final isLast = _currentIndex == _questions.length - 1;
        return Row(
          children: [
            _buildNavIconButton(
              icon: Icons.arrow_back_rounded,
              label: isFirst ? 'Back' : 'Previous',
              onTap: isFirst ? _backToIntro : _goPrevious,
              colorScheme: colorScheme,
              filled: false,
            ),
            const Spacer(),
            _buildNavIconButton(
              icon: isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
              label: isLast ? 'Finish' : 'Next',
              onTap: isAnswered ? _goNext : null,
              colorScheme: colorScheme,
              filled: true,
            ),
          ],
        );
      case _RiskStage.result:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _openPeerMentor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.people_alt_outlined),
                label: const Text('Talk to Mentor'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _openHealthService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.local_hospital_outlined),
                label: const Text('Get Service'),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildNavIconButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required ColorScheme colorScheme,
    required bool filled,
  }) {
    final isDisabled = onTap == null;
    final backgroundColor = filled
        ? (isDisabled ? colorScheme.primary.withOpacity(0.4) : colorScheme.primary)
        : Theme.of(context).cardColor;
    final foregroundColor = filled
        ? colorScheme.onPrimary
        : isDisabled
            ? colorScheme.outline
            : colorScheme.onSurface;
    final borderColor = filled ? Colors.transparent : colorScheme.outlineVariant;

    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 56,
            height: 46,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: foregroundColor),
          ),
        ),
      ),
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
      } else {
        _currentIndex += 1;
      }
    });
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

  String get _resultKeyMessage => _defaultRiskKeyMessage;
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

const String _defaultRiskKeyMessage =
    'Having a high-risk score does not mean that you are infected with HIV. '
    'However, if risky behaviors continue, there is a possibility of acquiring HIV infection. '
    'Therefore, make strong efforts to reduce your level of HIV exposure risk.';
