import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/startup/app_startup_service.dart';
import '../../../core/constants.dart';
import 'guest_page.dart';

const double _onboardingImageHeight = 297.04;

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final PageController _pageController = PageController();
  final AppStartupService _startupService = AppStartupService();
  Timer? _autoSlideTimer;

  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      asset: 'assets/images/landing-imageone.png',
      title: 'Learn and Assess',
      lineOne: 'Explore six health modules and take',
      lineTwo: 'an HIV risk assessment with guidance.',
      imageWidth: 378,
      variant: _SlideVariant.fullArt,
    ),
    _OnboardingSlide(
      asset: 'assets/images/landing-imagetwo.png',
      title: 'Get Services and Mentors',
      lineOne: 'Find nearby health facilities or connect',
      lineTwo: 'with peer mentors for support.',
      imageWidth: 378,
      variant: _SlideVariant.fullArt,
    ),
    _OnboardingSlide(
      asset: 'assets/images/landing-imagethree.png',
      title: 'Support for Young Girls',
      lineOne: 'Get trusted health guidance, safe support,',
      lineTwo: 'and care made for girls like you.',
      imageWidth: 378,
      variant: _SlideVariant.fullArt,
    ),
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _stopAutoSlide();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _stopAutoSlide();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      final nextPage = (_currentIndex + 1) % _slides.length;
      _pageController.animateToPage(
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

  Future<void> _handleGetStarted() async {
    await _startupService.markOnboardingCompleted();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GuestPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF123A59);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF3C627D);
    final surfaceColor = isDark ? const Color(0xFF0B1220) : Colors.white;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isLandscape ? 32 : 22,
            isLandscape ? 12 : 18,
            isLandscape ? 32 : 22,
            isLandscape ? 16 : 28,
          ),
          child: Column(
            children: [
              Expanded(
                child: Listener(
                  onPointerDown: (_) => _stopAutoSlide(),
                  onPointerUp: (_) => _startAutoSlide(),
                  onPointerCancel: (_) => _startAutoSlide(),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return _WelcomeSlide(
                        slide: slide,
                        currentIndex: _currentIndex,
                        slideCount: _slides.length,
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        isLandscape: isLandscape,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _PrimaryCta(
                label: 'Get Started',
                onPressed: _handleGetStarted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeSlide extends StatelessWidget {
  final _OnboardingSlide slide;
  final int currentIndex;
  final int slideCount;
  final bool isDark;
  final Color surfaceColor;
  final Color textColor;
  final Color subTextColor;
  final bool isLandscape;

  const _WelcomeSlide({
    required this.slide,
    required this.currentIndex,
    required this.slideCount,
    required this.isDark,
    required this.surfaceColor,
    required this.textColor,
    required this.subTextColor,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageBoxHeight = isLandscape
            ? (constraints.maxHeight * 0.5).clamp(150.0, 200.0)
            : (constraints.maxHeight - 120).clamp(220.0, 350.0);
        final imageHeight = isLandscape
            ? (imageBoxHeight - 20).clamp(130.0, 180.0)
            : (imageBoxHeight - 28).clamp(210.0, _onboardingImageHeight);
        final imageTop = isLandscape ? 10.0 : (imageBoxHeight > 300 ? 42.0 : 18.0);

        final content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: imageBoxHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 28,
                    child: slide.variant == _SlideVariant.fullArt
                        ? const SizedBox.shrink()
                        : Container(
                            width: 350,
                            height: 350,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  kPrimary.withOpacity(isDark ? 0.18 : 0.10),
                                  kPrimaryGlow.withOpacity(isDark ? 0.10 : 0.16),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 78,
                    child: slide.variant == _SlideVariant.fullArt
                        ? const SizedBox.shrink()
                        : Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: surfaceColor,
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimary.withOpacity(isDark ? 0.12 : 0.08),
                                  blurRadius: 28,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                  ),
                  Positioned.fill(
                    top: imageTop,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: slide.imageWidth,
                        height: imageHeight,
                        child: Image.asset(
                          slide.asset,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isLandscape ? 20 : 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              slide.lineOne,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isLandscape ? 13 : 15,
                height: 1.35,
                color: subTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              slide.lineTwo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isLandscape ? 13 : 15,
                height: 1.35,
                color: subTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slideCount,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == currentIndex
                        ? kPrimary
                        : kPrimary.withOpacity(isDark ? 0.24 : 0.16),
                    boxShadow: index == currentIndex
                        ? [
                            BoxShadow(
                              color: kPrimary.withOpacity(0.24),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ],
        );

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: content,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryCta({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 190,
        height: 54,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            elevation: 6,
            shadowColor: kPrimary.withOpacity(0.26),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_rounded, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final String asset;
  final String title;
  final String lineOne;
  final String lineTwo;
  final double imageWidth;
  final _SlideVariant variant;

  const _OnboardingSlide({
    required this.asset,
    required this.title,
    required this.lineOne,
    required this.lineTwo,
    required this.imageWidth,
    this.variant = _SlideVariant.defaultArt,
  });
}

enum _SlideVariant {
  defaultArt,
  fullArt,
}
