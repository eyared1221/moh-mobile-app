import 'package:flutter/material.dart';
import 'features/guest/presentation/guest_page.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/auth/presentation/signin_screen.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/learning/presentation/pages/learning_module_page.dart';
import 'features/profile/presentation/profile_page.dart';
import 'features/risk_assessment/presentation/pages/risk_assessment_page.dart';
import 'features/services/presentation/pages/clinic_page.dart';
import 'core/theme/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSavedTheme();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF005C8F);

    final light = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
      ),
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
        ),
      ),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.black87,
        displayColor: primaryColor,
      ),
    );

    final dark = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
      ),
      scaffoldBackgroundColor: const Color(0xFF0B1220),
      cardColor: const Color(0xFF161D2C),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
        ),
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Yegna Health',
          theme: light,
          darkTheme: dark,
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            final args = settings.arguments as Map<String, dynamic>?;
            final ageRange = args?['ageRange'] ?? '10-14';
            final userName = args?['userName'] ?? 'Yegna User';

            switch (settings.name) {
              case '/':
                return MaterialPageRoute(builder: (_) => const GuestPage());
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
              case '/profile':
                return MaterialPageRoute(
                  builder: (_) => ProfilePage(ageRange: ageRange, userName: userName),
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
                return MaterialPageRoute(builder: (_) => const GuestPage());
            }
          },
        );
      },
    );
  }
}
