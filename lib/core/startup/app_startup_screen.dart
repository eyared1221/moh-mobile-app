import 'package:flutter/material.dart';

import '../../features/guest/presentation/guest_page.dart';
import '../../features/guest/presentation/landing_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';
import 'app_startup_service.dart';
import 'startup_splash_screen.dart';

class AppStartupScreen extends StatefulWidget {
  const AppStartupScreen({super.key});

  @override
  State<AppStartupScreen> createState() => _AppStartupScreenState();
}

class _AppStartupScreenState extends State<AppStartupScreen> {
  final AppStartupService _startupService = AppStartupService();
  bool _isResolving = true;
  bool _showSplash = false;
  Widget? _splashTargetPage;
  Duration _splashDuration = const Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    _resolveStartup();
  }

  Future<void> _resolveStartup() async {
    final decision = await _startupService.resolveStartupDecision();
    if (!mounted) return;

    switch (decision.route) {
      case AppStartupRoute.onboarding:
        _showSplashBefore(
          const LandingScreen(),
          duration: const Duration(milliseconds: 1500),
        );
        return;
      case AppStartupRoute.home:
        _replaceWith(
          HomePage(
            age: decision.age,
            userName: decision.userName,
          ),
        );
        return;
      case AppStartupRoute.guest:
        _replaceWith(const GuestPage());
        return;
      case AppStartupRoute.guestAfterSplash:
        _showSplashBefore(const GuestPage());
        return;
    }
  }

  void _showSplashBefore(Widget page, {Duration? duration}) {
    setState(() {
      _isResolving = false;
      _showSplash = true;
      _splashTargetPage = page;
      _splashDuration = duration ?? const Duration(milliseconds: 1200);
    });
  }

  void _replaceWith(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return StartupSplashScreen(
        duration: _splashDuration,
        onComplete: () {
          final targetPage = _splashTargetPage;
          if (targetPage != null) {
            _replaceWith(targetPage);
          }
        },
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isResolving
          ? const SizedBox.expand()
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
