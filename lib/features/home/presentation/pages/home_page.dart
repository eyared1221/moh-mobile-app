import 'dart:ui';

import 'package:flutter/material.dart';

// Internal Widget Imports
import '../../../../shared/widgets/top_header.dart';
import '../../../../shared/widgets/hero_banner.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../learning/presentation/pages/learning_module_page.dart';
import '../../../services/presentation/clinic_page.dart';
import 'peer_mentor_page.dart';
import 'risk_assessment_page.dart';

class HomePage extends StatefulWidget {
  final String age;
  final String? userName;

  const HomePage({
    super.key,
    required this.age,
    this.userName,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _pressedNavIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final navCards = _buildNavCards();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildOriginalHeader(colorScheme),
            const SizedBox(height: 4),
            _buildSlantedHero(isDark, colorScheme),
            const SizedBox(height: 12),
            Expanded(
              child: _buildNavGrid(navCards, isDark, colorScheme),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        age: widget.age,
        currentIndex: 0,
        userName: widget.userName,
      ),
    );
  }

  Widget _buildOriginalHeader(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TopHeader(
              onBellTap: () {},
              showThemeToggle: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlantedHero(bool isDark, ColorScheme colorScheme) {
    return Center(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(-0.06)
          ..rotateY(0.03),
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          constraints: const BoxConstraints(minHeight: 95),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      colorScheme.onSurface.withOpacity(0.12),
                      colorScheme.onSurface.withOpacity(0.01),
                    ]
                  : [
                      colorScheme.surface,
                      colorScheme.surfaceVariant,
                    ],
            ),
            border: Border.all(
              color: isDark ? colorScheme.outlineVariant : colorScheme.surface,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: HeroBanner(
                title: "Empower Your Health, Break Stigma",
                subtitle: "",
                age: widget.age,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<_HomeNavCardData> _buildNavCards() {
    return [
      _HomeNavCardData(
        title: 'Risk Assessment',
        image: 'assets/images/assesment.png',
        icon: Icons.fact_check_outlined,
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RiskAssessmentPage()),
          );
        },
      ),
      _HomeNavCardData(
        title: 'Learning Module',
        image: 'assets/images/modules.png',
        icon: Icons.menu_book_outlined,
        onTap: (context) {
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
              builder: (_) => ClinicPage(
                ageRange: widget.age,
              ),
            ),
          );
        },
      ),
      _HomeNavCardData(
        title: 'Get Peer Mentor',
        image: 'assets/images/menter.png',
        icon: Icons.people_alt_outlined,
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PeerMentorPage()),
          );
        },
      ),
    ];
  }

  Widget _buildNavGrid(List<_HomeNavCardData> cards, bool isDark, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          return _buildNavCard(
            cards[index],
            isDark,
            index,
            colorScheme,
          );
        },
      ),
    );
  }

  Widget _buildNavCard(_HomeNavCardData data, bool isDark, int index, ColorScheme colorScheme) {
    final isPressed = _pressedNavIndex == index;
    const outerRadius = 22.0;

    return GestureDetector(
      onTap: () => data.onTap(context),
      onTapDown: (_) => setState(() => _pressedNavIndex = index),
      onTapUp: (_) => setState(() => _pressedNavIndex = null),
      onTapCancel: () => setState(() => _pressedNavIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(isPressed ? 0.97 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(outerRadius),
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
          color: isDark ? colorScheme.surface : Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(outerRadius),
          child: Column(
            children: [
              Expanded(
                flex: 11,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(2, 2, 2, 0),
                  child: Image.asset(
                    data.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: colorScheme.surfaceVariant,
                        alignment: Alignment.center,
                        child: Icon(
                          data.icon,
                          size: 36,
                          color: colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4, top: 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      data.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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
