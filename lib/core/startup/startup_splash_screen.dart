import 'package:flutter/material.dart';

class StartupSplashScreen extends StatefulWidget {
  const StartupSplashScreen({
    super.key,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 1200),
  });

  final Duration duration;
  final VoidCallback onComplete;

  @override
  State<StartupSplashScreen> createState() => _StartupSplashScreenState();
}

class _StartupSplashScreenState extends State<StartupSplashScreen> {
  static const String _startupLogoAsset = 'assets/images/logo.png';

  @override
  void initState() {
    super.initState();
    _finishSplash();
  }

  Future<void> _finishSplash() async {
    await Future<void>.delayed(widget.duration);
    if (!mounted) return;
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Image.asset(
            _startupLogoAsset,
            height: isDark ? 190 : 190,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.health_and_safety,
                size: 96,
                color: isDark ? Colors.white70 : const Color(0xFF005C8F),
              );
            },
          ),
        ),
      ),
    );
  }
}
