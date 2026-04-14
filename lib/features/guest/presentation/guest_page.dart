import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../shared/widgets/blue_card.dart';
import '../../../shared/widgets/faq_section.dart';
import '../../../shared/widgets/guest_bottom_nav.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/six_cards_section.dart';
import '../../auth/presentation/signin_screen.dart';

class GuestPage extends StatefulWidget {
  const GuestPage({super.key});

  @override
  State<GuestPage> createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _BackgroundGlow(
              size: 240,
              color: kPrimary.withOpacity(isDark ? 0.18 : 0.10),
            ),
          ),
          Positioned(
            top: 260,
            left: -90,
            child: _BackgroundGlow(
              size: 220,
              color: kPrimaryGlow.withOpacity(isDark ? 0.08 : 0.12),
            ),
          ),
          Positioned(
            bottom: 110,
            right: -60,
            child: _BackgroundGlow(
              size: 180,
              color: kPrimarySoftAlt.withOpacity(isDark ? 0.05 : 0.18),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AnimatedReveal(
                    controller: _controller,
                    start: 0.00,
                    child: BlueCard(
                      onSignUp: _openSignIn,
                    ),
                  ),
                  _AnimatedReveal(
                    controller: _controller,
                    start: 0.14,
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(18, 18, 18, 0),
                      child: SectionTitle(title: "General Health Information"),
                    ),
                  ),
                  _AnimatedReveal(
                    controller: _controller,
                    start: 0.24,
                    child: const SixCardsSection(),
                  ),
                  _AnimatedReveal(
                    controller: _controller,
                    start: 0.38,
                    child: const _GuestSpotlightPanel(),
                  ),
                  _AnimatedReveal(
                    controller: _controller,
                    start: 0.52,
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(18, 18, 18, 0),
                      child: SectionTitle(title: "FAQs"),
                    ),
                  ),
                  _AnimatedReveal(
                    controller: _controller,
                    start: 0.64,
                    child: const FaqSection(),
                  ),
                  _AnimatedReveal(
                    controller: _controller,
                    start: 0.76,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: Colors.white,
                            elevation: 10,
                            shadowColor: kPrimary.withOpacity(0.28),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _openSignIn,
                          child: const Text(
                            "Get Started",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const GuestBottomNav(),
    );
  }

  void _openSignIn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }
}

class _AnimatedReveal extends StatelessWidget {
  final AnimationController controller;
  final double start;
  final Widget child;

  const _AnimatedReveal({
    required this.controller,
    required this.start,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: controller,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundGlow({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 80,
              spreadRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestSpotlightPanel extends StatelessWidget {
  const _GuestSpotlightPanel();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF0E2235), Color(0xFF163B59)]
                : const [kPrimarySoft, kPrimarySoftAlt],
          ),
          border: Border.all(
            color: isDark ? Colors.white10 : kPrimaryStroke,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.24 : 0.10),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -28,
              right: -18,
              child: Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(isDark ? 0.06 : 0.35),
                ),
              ),
            ),
            Positioned(
              bottom: -36,
              left: -28,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimary.withOpacity(isDark ? 0.10 : 0.08),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learn, ask, and find support in one place.',
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF10304B),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Browse trusted youth-friendly health topics, discover nearby care, and connect with guidance when you are ready.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark
                        ? Colors.white.withOpacity(0.78)
                        : const Color(0xFF31536E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                const _GuestActionGrid(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestActionGrid extends StatelessWidget {
  const _GuestActionGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Row(
          children: [
            Expanded(
              child: _GuestActionCard(
                icon: Icons.menu_book_rounded,
                label: 'Quick Lessons',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _GuestActionCard(
                icon: Icons.location_on_outlined,
                label: 'Find Care',
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _GuestActionCard(
                icon: Icons.groups_2_outlined,
                label: 'Get Support',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _GuestActionCard(
                icon: Icons.fact_check_outlined,
                label: 'Ask Yourself',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GuestActionCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _GuestActionCard({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 108,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.07) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white10 : kPrimaryStroke,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.10 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: kPrimary.withOpacity(0.10),
            ),
            child: Icon(icon, size: 20, color: kPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF16324A),
            ),
          ),
        ],
      ),
    );
  }
}
