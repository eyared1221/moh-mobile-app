import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../risk_assessment/domain/entities/risk_option_entity.dart';
import '../../../risk_assessment/domain/entities/risk_question_entity.dart';
import '../../../risk_assessment/presentation/widgets/risk_assessment_question_page.dart';

class LearningModuleQuizPage extends StatefulWidget {
  final String age;
  final String? userName;
  final String moduleTitle;

  const LearningModuleQuizPage({
    super.key,
    required this.age,
    required this.userName,
    required this.moduleTitle,
  });

  @override
  State<LearningModuleQuizPage> createState() => _LearningModuleQuizPageState();
}

enum _QuizStage { questions, result }

class _LearningModuleQuizPageState extends State<LearningModuleQuizPage> {
  static const _QuizDefinition _hivQuiz = _QuizDefinition(
    title: 'HIV Module Quiz',
    questions: [
      RiskQuestionEntity(
        id: 'hiv-quiz-1',
        number: 1,
        title:
            'HIV infects and destroys cells of human immune system, making it hard to fight other diseases?',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. True'),
          RiskOptionEntity(label: 'B. False'),
        ],
      ),
      RiskQuestionEntity(
        id: 'hiv-quiz-2',
        number: 2,
        title:
            'Which of the following is/are correct about mode of HIV transmission?',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. Unprotected sexual practice'),
          RiskOptionEntity(
            label: 'B. HIV positive mother to their fetus or child',
          ),
          RiskOptionEntity(label: 'C. Eating together'),
          RiskOptionEntity(label: 'D. A & B'),
        ],
      ),
      RiskQuestionEntity(
        id: 'hiv-quiz-3',
        number: 3,
        title:
            'Which of the following is/are correct about methods of HIV prevention?',
        helper: '',
        options: [
          RiskOptionEntity(
            label: 'A. Abstinence from sex (not having sex), before marriage',
          ),
          RiskOptionEntity(
            label: 'B. Being faithful (decide to one sexual partner) after testing',
          ),
          RiskOptionEntity(
            label: 'C. Consistent and correct use of condom',
          ),
          RiskOptionEntity(label: 'D. All'),
        ],
      ),
      RiskQuestionEntity(
        id: 'hiv-quiz-4',
        number: 4,
        title:
            'Which of the following is a healthy way to support a friend living with HIV?',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. Avoid them'),
          RiskOptionEntity(label: 'B. Tell everyone about their status'),
          RiskOptionEntity(
            label:
                'C. Treat them with respect and encourage them to stay in care',
          ),
          RiskOptionEntity(label: 'D. Stop sharing meals with them'),
        ],
      ),
    ],
    correctOptionIndexes: [0, 3, 3, 2],
  );

  static const _QuizDefinition _stiQuiz = _QuizDefinition(
    title: 'STI Module Quiz',
    questions: [
      RiskQuestionEntity(
        id: 'sti-quiz-1',
        number: 1,
        title: 'Which sign and symptoms suggest sexually transmitted infection?',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. Unusual penile/vaginal discharge'),
          RiskOptionEntity(label: 'B. Pain during urination'),
          RiskOptionEntity(label: 'C. Itching around the genital area'),
          RiskOptionEntity(label: 'D. All'),
        ],
      ),
      RiskQuestionEntity(
        id: 'sti-quiz-2',
        number: 2,
        title:
            'Which of the following are true about complication of STI?',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. Ectopic pregnancy'),
          RiskOptionEntity(label: 'B. Infertility'),
          RiskOptionEntity(label: 'C. Pelvic inflammatory disease (PID)'),
          RiskOptionEntity(label: 'D. All'),
        ],
      ),
      RiskQuestionEntity(
        id: 'sti-quiz-3',
        number: 3,
        title:
            'To treat sexually transmitted infections properly, partner of clients who diagnosed with STI need be screened and treated for STI.',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. True'),
          RiskOptionEntity(label: 'B. False'),
        ],
      ),
      RiskQuestionEntity(
        id: 'sti-quiz-4',
        number: 4,
        title: 'How are STI commonly spread?',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. Sharing food'),
          RiskOptionEntity(label: 'B. Mosquito bites'),
          RiskOptionEntity(label: 'C. Unprotected sex'),
          RiskOptionEntity(label: 'D. Shaking hand'),
        ],
      ),
    ],
    correctOptionIndexes: [3, 3, 0, 2],
  );

  static const _QuizDefinition _hbvQuiz = _QuizDefinition(
    title: 'Hepatitis B Virus (HBV) Quiz',
    questions: [
      RiskQuestionEntity(
        id: 'hbv-quiz-1',
        number: 1,
        title:
            'Which of the following is a common route of Hepatitis B transmission?',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. Sharing food with an infected person'),
          RiskOptionEntity(label: 'B. Shaking hands with an infected person'),
          RiskOptionEntity(
            label: 'C. Unprotected sexual contact with an infected person',
          ),
          RiskOptionEntity(label: 'D. Sitting near an infected person'),
        ],
      ),
      RiskQuestionEntity(
        id: 'hbv-quiz-2',
        number: 2,
        title: 'Which practice can help prevent Hepatitis B infection?',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. Receiving the Hepatitis B vaccine'),
          RiskOptionEntity(label: 'B. Sharing needles with friends'),
          RiskOptionEntity(label: 'C. Using unsterilized sharp objects'),
          RiskOptionEntity(label: 'D. Avoiding physical exercise'),
        ],
      ),
      RiskQuestionEntity(
        id: 'hbv-quiz-3',
        number: 3,
        title: 'A person with Hepatitis B may:',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. Always show symptoms immediately'),
          RiskOptionEntity(label: 'B. Have no symptoms for a long time'),
          RiskOptionEntity(label: 'C. Lose hearing first'),
          RiskOptionEntity(label: 'D. Develop broken bones'),
        ],
      ),
      RiskQuestionEntity(
        id: 'hbv-quiz-4',
        number: 4,
        title: 'Which statement about Hepatitis B is correct?',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. It has no vaccine'),
          RiskOptionEntity(label: 'B. It only affects children'),
          RiskOptionEntity(label: 'C. It cannot become chronic'),
          RiskOptionEntity(label: 'D. It is preventable with a vaccine'),
        ],
      ),
      RiskQuestionEntity(
        id: 'hbv-quiz-5',
        number: 5,
        title: 'A serious complication of chronic hepatitis is:',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. Liver cancer'),
          RiskOptionEntity(label: 'B. Asthma'),
          RiskOptionEntity(label: 'C. Malaria'),
          RiskOptionEntity(label: 'D. Hypertension'),
        ],
      ),
    ],
    correctOptionIndexes: [2, 0, 1, 3, 0],
  );

  static const _QuizDefinition _gbvQuiz = _QuizDefinition(
    title: 'Gender-Based Violence (GBV) Quiz',
    questions: [
      RiskQuestionEntity(
        id: 'gbv-quiz-1',
        number: 1,
        title: 'Gender-Based Violence (GBV) refers to:',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. Violence caused by natural disasters'),
          RiskOptionEntity(
            label: 'B. Harmful acts directed at a person based on their gender',
          ),
          RiskOptionEntity(label: 'C. Violence occurring only in workplaces'),
          RiskOptionEntity(label: 'D. Violence affecting men only'),
        ],
      ),
      RiskQuestionEntity(
        id: 'gbv-quiz-2',
        number: 2,
        title: 'Which of the following are forms of GBV?',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. Withholding financial resources'),
          RiskOptionEntity(label: 'B. Isolation from family and friends'),
          RiskOptionEntity(label: 'C. Hitting or slapping a partner'),
          RiskOptionEntity(label: 'D. Verbal insults'),
          RiskOptionEntity(label: 'E. All'),
        ],
      ),
      RiskQuestionEntity(
        id: 'gbv-quiz-3',
        number: 3,
        title: 'What is the purpose of school programs on GBV prevention?',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. To encourage discrimination'),
          RiskOptionEntity(label: 'B. Punishing students'),
          RiskOptionEntity(label: 'C. To reduce school attendance'),
          RiskOptionEntity(
            label:
                'D. To promote respect, gender equality, and healthy relationships',
          ),
        ],
      ),
      RiskQuestionEntity(
        id: 'gbv-quiz-4',
        number: 4,
        title: 'What should survivors of GBV have access to?',
        helper: '',
        options: [
          RiskOptionEntity(
            label: 'A. Timely access to HIV prevention packages',
          ),
          RiskOptionEntity(label: 'B. Psychosocial support'),
          RiskOptionEntity(label: 'C. Legal support'),
          RiskOptionEntity(label: 'D. All'),
        ],
      ),
      RiskQuestionEntity(
        id: 'gbv-quiz-5',
        number: 5,
        title: 'Rape is classified under:',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. Economic violence'),
          RiskOptionEntity(label: 'B. Psychological violence'),
          RiskOptionEntity(label: 'C. Sexual violence'),
          RiskOptionEntity(label: 'D. Cultural violence'),
        ],
      ),
    ],
    correctOptionIndexes: [1, 4, 3, 3, 2],
  );

  static const _QuizDefinition _srhQuiz = _QuizDefinition(
    title: 'Sexual and Reproductive Health (SRH) Quiz',
    questions: [
      RiskQuestionEntity(
        id: 'srh-quiz-1',
        number: 1,
        title: 'What is sexual and reproductive health (SRH)?',
        helper: '',
        options: [
          RiskOptionEntity(
            label:
                'A. A state of physical, emotional, mental, and social well-being related to sexuality and reproduction',
          ),
          RiskOptionEntity(
            label: 'B. The absence of sexually transmitted infections only',
          ),
          RiskOptionEntity(label: 'C. The ability to have children only'),
          RiskOptionEntity(
            label: 'D. Receiving treatment for reproductive diseases only',
          ),
        ],
      ),
      RiskQuestionEntity(
        id: 'srh-quiz-2',
        number: 2,
        title:
            'Which contraceptive method can help prevent both pregnancy and sexually transmitted infections?',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. Condoms'),
          RiskOptionEntity(label: 'B. Birth control pills'),
          RiskOptionEntity(label: 'C. Implants'),
          RiskOptionEntity(label: 'D. IUDs'),
        ],
      ),
      RiskQuestionEntity(
        id: 'srh-quiz-3',
        number: 3,
        title:
            'Adolescents under 16 years who become pregnant are at increased risk of:',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. Reduced school performance'),
          RiskOptionEntity(label: 'B. Lower economic opportunities'),
          RiskOptionEntity(label: 'C. Reduced maternal health risks'),
          RiskOptionEntity(
            label: 'D. Preterm labor and low birth weight babies',
          ),
          RiskOptionEntity(label: 'E. All'),
        ],
      ),
      RiskQuestionEntity(
        id: 'srh-quiz-4',
        number: 4,
        title:
            'Adolescents are at increased risk of contracting STIs because of:',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. Stronger immunity'),
          RiskOptionEntity(
            label:
                'B. Biological vulnerabilities and limited access to protection or healthcare',
          ),
          RiskOptionEntity(label: 'C. Better health-seeking behavior'),
          RiskOptionEntity(label: 'D. Higher vaccination coverage'),
        ],
      ),
    ],
    correctOptionIndexes: [0, 0, 4, 1],
  );

  static const _QuizDefinition _substanceQuiz = _QuizDefinition(
    title: 'Substance Abuse Quiz',
    questions: [
      RiskQuestionEntity(
        id: 'substance-quiz-1',
        number: 1,
        title: 'What is substance abuse?',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. Eating healthy foods'),
          RiskOptionEntity(
            label:
                'B. Using alcohol, tobacco or other drugs (cocaine, heroin, morphine...)',
          ),
          RiskOptionEntity(label: 'C. Exercising regularly'),
          RiskOptionEntity(label: 'D. Drinking clean water'),
        ],
      ),
      RiskQuestionEntity(
        id: 'substance-quiz-2',
        number: 2,
        title:
            'Why can alcohol or drug use increase the risk of HIV and other STI?',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. It improves decision making'),
          RiskOptionEntity(
            label:
                'B. It can make people more likely to have unprotected sex or take other risks',
          ),
          RiskOptionEntity(label: 'C. It prevents infection'),
          RiskOptionEntity(label: 'D. It strengths the immune system'),
        ],
      ),
      RiskQuestionEntity(
        id: 'substance-quiz-3',
        number: 3,
        title:
            'Which one of the following is possible effects of substance abuse?',
        helper: '',
        options: [
          RiskOptionEntity(label: 'A. Better concentration'),
          RiskOptionEntity(
            label: 'B. Increased risk of disease (like liver disease, HIV)',
          ),
          RiskOptionEntity(label: 'C. Better school performance'),
          RiskOptionEntity(label: 'D. Improved memory'),
        ],
      ),
    ],
    correctOptionIndexes: [1, 1, 1],
  );

  late final _QuizDefinition _quizDefinition;
  late List<int?> _selectedOptionIndexes;
  _QuizStage _stage = _QuizStage.questions;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _quizDefinition = _resolveQuizDefinition(widget.moduleTitle);
    _selectedOptionIndexes =
        List<int?>.filled(_quizDefinition.questions.length, null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: isDark ? Colors.white : colorScheme.primary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_quizDefinition.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _stage == _QuizStage.questions
                ? RiskAssessmentQuestionPage(
                    key: ValueKey('quiz-question-$_currentIndex'),
                    question: _quizDefinition.questions[_currentIndex],
                    currentQuestion: _currentIndex + 1,
                    totalQuestions: _quizDefinition.questions.length,
                    selectedIndex: _selectedOptionIndexes[_currentIndex],
                    onSelectOption: _selectOption,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    isFirst: _currentIndex == 0,
                    isAnswered: _selectedOptionIndexes[_currentIndex] != null,
                    isLast:
                        _currentIndex == _quizDefinition.questions.length - 1,
                    onPrevious: _currentIndex == 0 ? _exitQuiz : _goPrevious,
                    onNext: _goNext,
                  )
                : _QuizResultView(
                    key: const ValueKey('quiz-result'),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    score: _score,
                    totalQuestions: _quizDefinition.questions.length,
                    questions: _quizDefinition.questions,
                    selectedOptionIndexes: _selectedOptionIndexes,
                    correctOptionIndexes:
                        _quizDefinition.correctOptionIndexes,
                    onRetakeQuiz: _resetQuiz,
                  ),
          ),
        ),
      ),
      bottomNavigationBar: _stage == _QuizStage.result
          ? AppBottomNav(
              age: widget.age,
              currentIndex: 1,
              userName: widget.userName,
            )
          : null,
    );
  }

  int get _score {
    var score = 0;
    for (var index = 0; index < _quizDefinition.questions.length; index += 1) {
      if (_selectedOptionIndexes[index] ==
          _quizDefinition.correctOptionIndexes[index]) {
        score += 1;
      }
    }
    return score;
  }

  void _selectOption(int index) {
    setState(() {
      _selectedOptionIndexes[_currentIndex] = index;
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
    final isLast = _currentIndex == _quizDefinition.questions.length - 1;
    setState(() {
      if (isLast) {
        _stage = _QuizStage.result;
      } else {
        _currentIndex += 1;
      }
    });
  }

  void _resetQuiz() {
    setState(() {
      _stage = _QuizStage.questions;
      _currentIndex = 0;
      _selectedOptionIndexes =
          List<int?>.filled(_quizDefinition.questions.length, null);
    });
  }

  void _exitQuiz() {
    Navigator.pop(context);
  }

  _QuizDefinition _resolveQuizDefinition(String moduleTitle) {
    final normalizedTitle = moduleTitle.toLowerCase();

    if (normalizedTitle.contains('sti') ||
        normalizedTitle.contains('sexually transmitted')) {
      return _stiQuiz;
    }

    if (normalizedTitle.contains('hepatitis') ||
        normalizedTitle.contains('hbv')) {
      return _hbvQuiz;
    }

    if (normalizedTitle.contains('gbv') ||
        normalizedTitle.contains('gender-based') ||
        normalizedTitle.contains('gender based') ||
        normalizedTitle.contains('violence')) {
      return _gbvQuiz;
    }

    if (normalizedTitle.contains('srh') ||
        normalizedTitle.contains('sexual and reproductive')) {
      return _srhQuiz;
    }

    if (normalizedTitle.contains('substance') ||
        normalizedTitle.contains('abuse') ||
        normalizedTitle.contains('alcohol') ||
        normalizedTitle.contains('drug')) {
      return _substanceQuiz;
    }

    return _hivQuiz;
  }
}

class _QuizDefinition {
  final String title;
  final List<RiskQuestionEntity> questions;
  final List<int> correctOptionIndexes;

  const _QuizDefinition({
    required this.title,
    required this.questions,
    required this.correctOptionIndexes,
  });
}

class _QuizResultView extends StatelessWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final int score;
  final int totalQuestions;
  final List<RiskQuestionEntity> questions;
  final List<int?> selectedOptionIndexes;
  final List<int> correctOptionIndexes;
  final VoidCallback onRetakeQuiz;

  const _QuizResultView({
    super.key,
    required this.colorScheme,
    required this.textTheme,
    required this.score,
    required this.totalQuestions,
    required this.questions,
    required this.selectedOptionIndexes,
    required this.correctOptionIndexes,
    required this.onRetakeQuiz,
  });

  @override
  Widget build(BuildContext context) {
    final passed = score == totalQuestions;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withOpacity(0.18),
                  colorScheme.surfaceVariant.withOpacity(0.18),
                ],
              ),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    passed ? Icons.verified_outlined : Icons.school_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quiz Complete',
                        style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ) ??
                            TextStyle(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You got $score out of $totalQuestions correct.',
                        style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ) ??
                            TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Answer Review',
            style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ) ??
                TextStyle(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 12),
          ...questions.asMap().entries.map((entry) {
            final questionIndex = entry.key;
            final question = entry.value;
            final selectedIndex = selectedOptionIndexes[questionIndex];
            final correctIndex = correctOptionIndexes[questionIndex];
            final isCorrect = selectedIndex == correctIndex;
            final selectedLabel = selectedIndex == null
                ? 'Not answered'
                : question.options[selectedIndex].label;
            final correctLabel = question.options[correctIndex].label;
            final accentColor = isCorrect ? Colors.green : colorScheme.error;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: accentColor.withOpacity(0.28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${question.number}. ${question.title}',
                            style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  height: 1.4,
                                ) ??
                                TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  height: 1.4,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          isCorrect
                              ? Icons.check_circle_outline
                              : Icons.highlight_off,
                          color: accentColor,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your answer: $selectedLabel',
                      style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ) ??
                          TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Correct answer: $correctLabel',
                      style: textTheme.bodySmall?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w700,
                          ) ??
                          TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRetakeQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Retake Quiz',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
