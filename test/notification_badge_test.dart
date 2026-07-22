import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yegna_health/shared/widgets/notification_badge.dart';

void main() {
  group('NotificationBadge Tests', () {
    testWidgets('displays badge with count when count > 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationBadge(
              count: 5,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      // Check if the badge is displayed
      expect(find.text('5'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('does not display badge when count is 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationBadge(
              count: 0,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      // Check if the badge is not displayed
      expect(find.text('0'), findsNothing);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('displays 99+ when count > 99', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationBadge(
              count: 150,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      // Check if the badge shows "99+"
      expect(find.text('99+'), findsOneWidget);
    });
  });
}
