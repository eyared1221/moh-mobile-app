import 'package:flutter_test/flutter_test.dart';
import 'package:yegna_health/main.dart'; // Ensure this matches your project name

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    // 1. We use MyApp() because that is the class name in your main.dart
    await tester.pumpWidget(const MyApp());

    // 2. Check if the app starts by looking for a piece of text.
    // Since your initial route is LandingScreen, it should find text from there.
    // Replace 'GET STARTED' with whatever button or title text is on your LandingScreen.
    expect(find.textContaining('GET STARTED'), findsOneWidget);
  });
}