import 'package:shared_preferences/shared_preferences.dart';

enum AppStartupRoute {
  onboarding,
  guest,
  guestAfterSplash,
  home,
}

class AppStartupDecision {
  const AppStartupDecision({
    required this.route,
    this.userName,
    this.age = '10-14',
  });

  final AppStartupRoute route;
  final String? userName;
  final String age;
}

class AppStartupService {
  static const hasCompletedOnboardingKey = 'hasCompletedOnboarding';
  static const lastActiveAtKey = 'lastActiveAt';
  static const inactivityThreshold = Duration(days: 3);

  Future<AppStartupDecision> resolveStartupDecision() async {
    final prefs = await SharedPreferences.getInstance();

    final hasCompletedOnboarding =
        prefs.getBool(hasCompletedOnboardingKey) ?? false;
    if (!hasCompletedOnboarding) {
      return const AppStartupDecision(route: AppStartupRoute.onboarding);
    }

    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final authToken = prefs.getString('authToken')?.trim() ?? '';
    final hasValidSession = isLoggedIn && authToken.isNotEmpty;
    final isFrequentUser = _isFrequentUser(prefs);

    final userName = prefs.getString('userName')?.trim();
    final storedAge = prefs.getString('userAge')?.trim();
    final age = storedAge == null || storedAge.isEmpty ? '10-14' : storedAge;

    if (hasValidSession && isFrequentUser) {
      return AppStartupDecision(
        route: AppStartupRoute.home,
        userName: userName?.isEmpty ?? true ? null : userName,
        age: age,
      );
    }

    if (isFrequentUser) {
      return const AppStartupDecision(route: AppStartupRoute.guest);
    }

    return const AppStartupDecision(route: AppStartupRoute.guestAfterSplash);
  }

  Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hasCompletedOnboardingKey, true);
  }

  Future<void> recordLastActiveAt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      lastActiveAtKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  bool _isFrequentUser(SharedPreferences prefs) {
    final lastActiveAtMillis = prefs.getInt(lastActiveAtKey);
    if (lastActiveAtMillis == null) {
      return false;
    }

    final lastActiveAt = DateTime.fromMillisecondsSinceEpoch(lastActiveAtMillis);
    return DateTime.now().difference(lastActiveAt) <= inactivityThreshold;
  }
}
