import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campu_notify/main.dart';
import 'package:campu_notify/features/auth/presentation/providers/auth_provider.dart';

class FakeAuthNotifier extends AuthNotifier {
  @override
  Future<bool> build() async => false;
}

void main() {
  testWidgets('Smoke test: halaman login tampil saat awal buka tanpa token',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialAuthCheckProvider.overrideWithValue(const AsyncData(false)),
          authStateProvider.overrideWith(FakeAuthNotifier.new),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump();
    await tester.pump();

    // Pastikan halaman login dimuat
    expect(find.text('Login Campus Notify'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Masuk'), findsOneWidget);
  });
}
