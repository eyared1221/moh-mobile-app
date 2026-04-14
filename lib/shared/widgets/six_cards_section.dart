import 'dart:async';

import 'package:flutter/material.dart';

class SixCardsSection extends StatefulWidget {
  const SixCardsSection({super.key});

  @override
  State<SixCardsSection> createState() => _SixCardsSectionState();
}

class _SixCardsSectionState extends State<SixCardsSection> {
  static const _images = [
    'assets/images/slide-image1.png',
    'assets/images/slide-image2.png',
    'assets/images/slide-image3.png',
    'assets/images/slide-image4.png',
    'assets/images/slide-image5.png',
    'assets/images/slide-image6.png',
  ];

  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
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
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      _currentPage = (_currentPage + 1) % _images.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 362,
      child: Column(
        children: [
          Expanded(
            child: Listener(
              onPointerDown: (_) => _stopAutoSlide(),
              onPointerUp: (_) => _startAutoSlide(),
              onPointerCancel: (_) => _startAutoSlide(),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 18 : 8,
                      right: index == _images.length - 1 ? 18 : 8,
                      top: 10,
                      bottom: 8,
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset(
                        _images[index],
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentPage
                      ? colorScheme.primary
                      : colorScheme.primary.withOpacity(0.24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
