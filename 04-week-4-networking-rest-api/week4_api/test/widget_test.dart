import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Widget dasar bisa dirender tanpa error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Hello'),
        ),
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
  });
}