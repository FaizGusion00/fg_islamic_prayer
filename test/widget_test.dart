// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fgislamic_prayer/main.dart';

void main() {
  testWidgets('FGIslamicPrayerApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FGIslamicPrayerApp());

    // Verify that the app loads with bottom navigation.
    expect(find.text('Prayer Times'), findsOneWidget);
    expect(find.text('Qibla'), findsOneWidget);
    expect(find.text('Donation'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Verify navigation icons are present.
    expect(find.byIcon(Icons.access_time), findsOneWidget);
    expect(find.byIcon(Icons.explore), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
