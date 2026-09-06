import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/cupertino.dart';

import 'package:responsive_dashboard/main.dart';

void main() {
  testWidgets('Dashboard shows profile and info cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DashboardApp());

    expect(find.text('AngelBoard'), findsOneWidget);
    expect(find.text('Angel Chelssa'), findsOneWidget);
    expect(find.text('Assignments'), findsOneWidget);
  });

  testWidgets('Dashboard satu kolom di layar sempit (<700px)',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());
    await tester.pumpAndSettle();

    final cardFinder = find.byType(Card).first;
    final width = tester.getSize(cardFinder).width;

    expect(width, lessThan(kWideBreakpoint));
  });

  testWidgets('Dashboard dua kolom di layar lebar (>=700px)',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());
    await tester.pumpAndSettle();

    final cardFinder = find.byType(Card).first;
    final width = tester.getSize(cardFinder).width;

    expect(width, greaterThan(500));
  });

  testWidgets('Toggle dark mode mengubah ThemeMode', (tester) async {
    await tester.pumpWidget(const DashboardApp());
    await tester.pumpAndSettle();

    final materialAppBefore =
        tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialAppBefore.themeMode, ThemeMode.light);

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();

    final materialAppAfter =
        tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialAppAfter.themeMode, ThemeMode.dark);
  });

  testWidgets('Semantics label profil dan kartu info tersedia',
      (tester) async {
    await tester.pumpWidget(const DashboardApp());
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(
          'Profil siswa: Angel Chelssa, D-IV Teknik Informatika, 244107020202'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Assignments: 8'), findsOneWidget);
  });
}