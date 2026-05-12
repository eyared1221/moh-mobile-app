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
  static const String _lightLaunchAsset =
      'android/app/src/main/res/drawable-nodpi/native_launch_light.png';
  static const String _darkLaunchAsset =
      'android/app/src/main/res/drawable-nodpi/native_launch_dark.png';

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
      body: SizedBox.expand(
        child: Image.asset(
          isDark ? _darkLaunchAsset : _lightLaunchAsset,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
