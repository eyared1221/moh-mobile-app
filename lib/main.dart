import 'dart:async';

import 'package:flutter/material.dart';
import 'features/notifications/data/notification_automation_service.dart';
import 'features/notifications/data/push_notification_service.dart';
import 'core/startup/app_startup_screen.dart';
import 'core/startup/app_startup_service.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/auth/presentation/signin_screen.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/learning/presentation/pages/learning_module_page.dart';
import 'features/mentor/presentation/pages/mentor_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/risk_assessment/presentation/pages/risk_assessment_page.dart';
import 'features/services/presentation/pages/clinic_page.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSavedTheme();
  await PushNotificationService.instance.initialize();
  await NotificationAutomationService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final AppStartupService _startupService = AppStartupService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(NotificationAutomationService.instance.handleAppForegrounded());
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _startupService.recordLastActiveAt();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Yegna Health',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            final args = settings.arguments as Map<String, dynamic>?;
            final ageRange = args?['ageRange'] ?? '10-14';
            final userName = args?['userName'] ?? 'Yegna User';

            switch (settings.name) {
              case '/':
                return MaterialPageRoute(builder: (_) => const AppStartupScreen());
              case '/signin':
                return MaterialPageRoute(builder: (_) => const SignInScreen());
              case '/signup':
                return MaterialPageRoute(builder: (_) => const SignUpScreen());
              case '/home':
                return MaterialPageRoute(
                  builder: (_) => HomePage(age: ageRange, userName: userName),
                );
              case '/clinic':
                return MaterialPageRoute(
                  builder: (_) => ClinicPage(age: ageRange, userName: userName),
                );
              case '/mentor':
                return MaterialPageRoute(
                  builder: (_) => MentorPage(
                    age: ageRange,
                    userName: userName,
                  ),
                );
              case '/profile':
                return MaterialPageRoute(
                  builder: (_) => ProfilePage(age: ageRange, userName: userName),
                );
              case '/learning':
                return MaterialPageRoute(
                  builder: (_) => LearningModulesPage(
                    age: ageRange,
                    userName: userName,
                  ),
                );

              case '/risk-assessment':
                return MaterialPageRoute(
                  builder: (_) => RiskAssessmentPage(
                    age: ageRange,
                    userName: userName,
                  ),
                );
              default:
                return MaterialPageRoute(builder: (_) => const AppStartupScreen());
            }
          },
        );
      },
    );
  }
}
