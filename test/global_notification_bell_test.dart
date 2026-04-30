import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yegna_health/features/notifications/data/notification_provider.dart';
import 'package:yegna_health/shared/widgets/global_notification_bell.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    NotificationProvider().resetUnreadCount();
  });

  testWidgets('shows the same global unread count everywhere it is reused', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'app_notifications': jsonEncode([
        {
          'id': 'notif-1',
          'type': 'general',
          'title': 'Unread',
          'message': 'Global notification',
          'createdAt': DateTime(2026, 4, 29).toIso8601String(),
          'readAt': null,
        },
      ]),
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              GlobalNotificationBell(),
              GlobalNotificationBell(),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('1'), findsNWidgets(2));
    expect(find.byIcon(Icons.notifications_none), findsNWidgets(2));
  });

  testWidgets('shows EN and sync next to the shared notification bell', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'app_notifications': jsonEncode([
        {
          'id': 'notif-1',
          'type': 'general',
          'title': 'Unread',
          'message': 'Global notification',
          'createdAt': DateTime(2026, 4, 29).toIso8601String(),
          'readAt': null,
        },
      ]),
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlobalTopBarActions(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('EN'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    expect(find.byIcon(Icons.sync), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });
}
