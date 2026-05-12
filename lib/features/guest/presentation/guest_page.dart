import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants.dart';
import '../../../shared/widgets/faq_section.dart';
import '../../../shared/widgets/guest_bottom_nav.dart';
import '../../auth/presentation/signin_screen.dart';

class GuestPage extends StatefulWidget {
  const GuestPage({super.key});

  @override
  State<GuestPage> createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _healthInfoKey = GlobalKey();
  final PageController _healthPageController =
      PageController(viewportFraction: 1);
  Timer? _autoSlideTimer;

  static const List<String> _healthCards = [
    'assets/images/slide-image1.png',
    'assets/images/slide-image2.png',
    'assets/images/slide-image3.png',
    'assets/images/slide-image4.png',
    'assets/images/slide-image5.png',
    'assets/images/slide-image6.png',
  ];

  int _currentHealthPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _stopAutoSlide();
    _controller.dispose();
    _scrollController.dispose();
    _healthPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final overlayStyle = isDark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: const Color(0xFF1E293B),
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.white,
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: scaffoldColor,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AnimatedReveal(
                  controller: _controller,
                  start: 0.0,
                  child: _GuestHeader(
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 18),
                _AnimatedReveal(
                  controller: _controller,
                  start: 0.12,
                  child: _GreetingBlock(isDark: isDark),
                ),
                const SizedBox(height: 18),
                _AnimatedReveal(
                  controller: _controller,
                  start: 0.22,
                  child: _FeatureGrid(
                    onRiskAssessment: _openSignIn,
                    onLearn: _openSignIn,
                    onFindClinic: _openSignIn,
                    onPeerMentor: _openSignIn,
                  ),
                ),
                const SizedBox(height: 18),
                _AnimatedReveal(
                  controller: _controller,
                  start: 0.34,
                  child: _SectionHeader(
                    key: _healthInfoKey,
                    title: 'Health Information',
                    actionLabel: 'View all',
                    onTap: _openSignIn,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 14),
                _AnimatedReveal(
                  controller: _controller,
                  start: 0.42,
                  child: _HealthInfoCarousel(
                    controller: _healthPageController,
                    cards: _healthCards,
                    currentIndex: _currentHealthPage,
                    isDark: isDark,
                    onInteractionStart: _stopAutoSlide,
                    onInteractionEnd: _startAutoSlide,
                    onPageChanged: (index) {
                      setState(() {
                        _currentHealthPage = index;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 18),
                _AnimatedReveal(
                  controller: _controller,
                  start: 0.54,
                  child: _SectionHeader(
                    title: 'Frequently Asked Questions',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 14),
                _AnimatedReveal(
                  controller: _controller,
                  start: 0.64,
                  child: const FaqSection(),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const GuestBottomNav(),
      ),
    );
  }

  void _openSignIn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  Future<void> _scrollToHealthInfo() async {
    final targetContext = _healthInfoKey.currentContext;
    if (targetContext == null) {
      return;
    }

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  void _startAutoSlide() {
    _stopAutoSlide();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_healthPageController.hasClients) {
        return;
      }

      final nextPage = (_currentHealthPage + 1) % _healthCards.length;
      _healthPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = null;
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
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class _GuestHeader extends StatelessWidget {
  final bool isDark;

  const _GuestHeader({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161D2C) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF123A59).withOpacity(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yegna Health',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF16324C),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Together for Better Health',
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF6C7C8F),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notifications_none_rounded,
            color: isDark ? Colors.white : const Color(0xFF16324C),
            size: 26,
          ),
        ),
      ],
    );
  }
}

class _GreetingBlock extends StatelessWidget {
  final bool isDark;

  const _GreetingBlock({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to Yegna Health',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF16324C),
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'What would you like to do today?',
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF73849A),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  final VoidCallback onRiskAssessment;
  final VoidCallback onLearn;
  final VoidCallback onFindClinic;
  final VoidCallback onPeerMentor;

  const _FeatureGrid({
    required this.onRiskAssessment,
    required this.onLearn,
    required this.onFindClinic,
    required this.onPeerMentor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: _FeatureCard(
                icon: Icons.assignment_rounded,
                title: 'Self Check',
                description: 'Check your health and get guidance',
                onTap: onRiskAssessment,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _FeatureCard(
                icon: Icons.menu_book_rounded,
                title: 'Learn',
                description: 'Explore health topics and resources',
                onTap: onLearn,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _FeatureCard(
                icon: Icons.local_hospital_rounded,
                title: 'Find Clinic',
                description: 'Locate nearby health facilities',
                onTap: onFindClinic,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _FeatureCard(
                icon: Icons.groups_rounded,
                title: 'Peer Mentor',
                description: 'Connect with mentors for support',
                onTap: onPeerMentor,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 180;

        return Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161D2C) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white10 : const Color(0xFFE7EDF4),
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: const Color(0xFF123A59).withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: isCompact ? 140 : 130),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: isCompact ? 44 : 48,
                        height: isCompact ? 44 : 48,
                        decoration: BoxDecoration(
                          color: isDark
                              ? kPrimary.withOpacity(0.16)
                              : const Color(0xFFF1F7FD),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          icon,
                          size: isCompact ? 24 : 26,
                          color: const Color(0xFF1764B1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF17324D),
                        fontSize: isCompact ? 16 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            isDark ? Colors.white70 : const Color(0xFF6B7D90),
                        fontSize: isCompact ? 12 : 12,
                        height: 1.3,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;
  final bool isDark;

  const _SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF16324C),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1764B1),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            ),
            child: Row(
              children: [
                Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ),
      ],
    );
  }
}

class _HealthInfoCarousel extends StatelessWidget {
  final PageController controller;
  final List<String> cards;
  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onInteractionStart;
  final VoidCallback onInteractionEnd;

  const _HealthInfoCarousel({
    required this.controller,
    required this.cards,
    required this.currentIndex,
    required this.isDark,
    required this.onPageChanged,
    required this.onInteractionStart,
    required this.onInteractionEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = (constraints.maxWidth * 0.62).clamp(180.0, 240.0);

        return Column(
          children: [
            SizedBox(
              height: cardHeight,
              child: Listener(
                onPointerDown: (_) => onInteractionStart(),
                onPointerUp: (_) => onInteractionEnd(),
                onPointerCancel: (_) => onInteractionEnd(),
                child: PageView.builder(
                  controller: controller,
                  itemCount: cards.length,
                  onPageChanged: onPageChanged,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 2,
                        right: index == cards.length - 1 ? 0 : 2,
                        bottom: 2,
                      ),
                      child: _HealthInfoCard(
                        asset: cards[index],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                cards.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == currentIndex
                        ? kPrimary
                        : kPrimary.withOpacity(isDark ? 0.22 : 0.20),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HealthInfoCard extends StatelessWidget {
  final String asset;

  const _HealthInfoCard({
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: ColoredBox(
        color: Colors.transparent,
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
