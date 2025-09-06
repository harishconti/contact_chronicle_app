// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:contact_chronicle/main.dart'; // Corrected import

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the LoginScreen shows the sign-in button.
    expect(find.text('Sign in with Google'), findsOneWidget);

    // Example: Verify that the app icon is present (if you added a Key to it or use find.byIcon)
    // expect(find.byIcon(LucideIcons.contact), findsOneWidget); // LucideIcons might need specific handling in tests
  });
}
