import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/global_notification_bell.dart';
import '../../../learning/data/learning_service.dart';
import '../../../learning/presentation/pages/learning_module_page.dart';
import '../../../mentor/data/mentor_repository.dart';
import '../../../mentor/presentation/pages/mentor_page.dart';
import '../../../notifications/data/notification_automation_service.dart';
import '../../../risk_assessment/data/risk_assessment_repository.dart';
import '../../../risk_assessment/presentation/pages/risk_assessment_page.dart';
import 'health_service_page.dart';
import '../../../services/data/clinic_repository.dart';

class HomePage extends StatefulWidget {
  final String age;
  final String? userName;

  const HomePage({super.key, required this.age, this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _pressedNavIndex;

  Future<void> _syncHomeData() async {
    await Future.wait<dynamic>([
      LearningService.instance.getLearningModules(),
      MentorRepository().fetchMentors(),
      RiskAssessmentRepository().fetchQuestions(),
      ClinicRepository().fetchClinics(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final navCards = _buildNavCards();
    final pageBackground = isDark ? const Color(0xFF0B1220) : const Color(0xFFF4F8FE);
    final pageGradient = isDark
        ? const [
            Color(0xFF0B1220),
            Color(0xFF11192A),
            Color(0xFF0E1625),
          ]
        : const [
            Color(0xFFF4F8FE),
            Color(0xFFF1F5FC),
            Color(0xFFF7FAFF),
          ];

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Health Support',
          style: TextStyle(
            color: isDark ? Colors.white : colorScheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          GlobalTopBarActions(
            onSyncPressed: _syncHomeData,
            color: colorScheme.primary,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: pageGradient,
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: Column(
                    children: [
                      _buildSupportHeroCard(isDark, colorScheme),
                      const SizedBox(height: 18),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: navCards.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.94,
                        ),
                        itemBuilder: (context, index) {
                          return _buildNavCard(
                            navCards[index],
                            isDark,
                            index,
                            colorScheme,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        age: widget.age,
        currentIndex: 0,
        userName: widget.userName,
      ),
    );
  }

  Widget _buildSupportHeroCard(
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF162033),
                  Color(0xFF101A2B),
                ]
              : const [
                  Color(0xFFFFFFFF),
                  Color(0xFFF2F7FF),
                ],
        ),
        border: Border.all(
          color: isDark
              ? colorScheme.outlineVariant.withOpacity(0.28)
              : const Color(0xFFE6EEF8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB9C8E6).withOpacity(isDark ? 0.12 : 0.22),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SizedBox(
        height: 178,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 360;
            final titleFontSize = isCompact ? 20.5 : 22.0;
            final subtitleFontSize = isCompact ? 12.7 : 13.4;
            final imageWidth = isCompact ? 158.0 : 182.0;
            final imageRight = isCompact ? -4.0 : -2.0;
            final imageTop = isCompact ? 14.0 : 10.0;
            final textRightInset = isCompact ? 138.0 : 160.0;

            return Stack(
              children: [
                Positioned(
                  left: 22,
                  top: 26,
                  right: textRightInset,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Your Sexual and Reproductive Support',
                        maxLines: 3,
                        style: textTheme.headlineSmall?.copyWith(
                          fontSize: titleFontSize,
                          height: 1.16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.25,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Empowerment, guidance, support and trusted learning resources',
                        maxLines: 2,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: subtitleFontSize,
                          height: 1.45,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: imageTop,
                  right: imageRight,
                  width: imageWidth,
                  height: 150,
                  child: Image.asset(
                    'assets/images/homepage.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.centerRight,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_HomeNavCardData> _buildNavCards() {
    return [
      _HomeNavCardData(
        title: 'Self-Assessment',
        image: 'assets/images/assesment.png',
        icon: Icons.fact_check_outlined,
        onTap: (context) {
          unawaited(
            NotificationAutomationService.instance.recordHomeFeatureOpened(
              featureKey:
                  NotificationAutomationService.homeFeatureSelfAssessmentKey,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RiskAssessmentPage(
                age: widget.age,
                userName: widget.userName,
              ),
            ),
          );
        },
      ),
      _HomeNavCardData(
        title: 'Learning Module',
        image: 'assets/images/modules.png',
        icon: Icons.menu_book_outlined,
        onTap: (context) {
          unawaited(
            NotificationAutomationService.instance.recordHomeFeatureOpened(
              featureKey:
                  NotificationAutomationService.homeFeatureLearningModuleKey,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LearningModulesPage(
                age: widget.age,
                userName: widget.userName,
              ),
            ),
          );
        },
      ),
      _HomeNavCardData(
        title: 'Get Health Service',
        image: 'assets/images/clinic.png',
        icon: Icons.local_hospital_outlined,
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HealthServicePage(
                age: widget.age,
                userName: widget.userName,
              ),
            ),
          );
        },
      ),
      _HomeNavCardData(
        title: 'Get Peer Mentor',
        image: 'assets/images/getmentor.png',
        icon: Icons.people_alt_outlined,
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MentorPage(
                age: widget.age,
                userName: widget.userName,
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildNavCard(
    _HomeNavCardData data,
    bool isDark,
    int index,
    ColorScheme colorScheme,
  ) {
    final isPressed = _pressedNavIndex == index;
    const outerRadius = 24.0;
    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final footerColor = isDark ? const Color(0xFF0F1928) : Colors.white;
    final titleColor = isDark ? colorScheme.primary : const Color(0xFF0B5F82);
    final fallbackBackground = isDark ? const Color(0xFF1B273A) : const Color(0xFFF2F7FF);
    final fallbackIconColor = isDark ? colorScheme.primary.withOpacity(0.95) : const Color(0xFF0B6F95);

    return GestureDetector(
      onTap: () => data.onTap(context),
      onTapDown: (_) => setState(() => _pressedNavIndex = index),
      onTapUp: (_) => setState(() => _pressedNavIndex = null),
      onTapCancel: () => setState(() => _pressedNavIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(isPressed ? 0.975 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(outerRadius),
          border: Border.all(
            color: isDark
                ? colorScheme.outlineVariant.withOpacity(0.28)
                : const Color(0xFFE8EEF7),
            width: 1,
          ),
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.10 : 0.045),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(outerRadius),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Image.asset(
                    data.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: fallbackBackground,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          data.icon,
                          size: 36,
                          color: fallbackIconColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                height: 48,
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: footerColor,
                ),
                child: Text(
                  data.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.08,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeNavCardData {
  final String title;
  final String image;
  final IconData icon;
  final void Function(BuildContext context) onTap;

  const _HomeNavCardData({
    required this.title,
    required this.image,
    required this.icon,
    required this.onTap,
  });
}
