import 'package:flutter_test/flutter_test.dart';

import 'package:responsive_dashboard/main.dart';

void main() {
  testWidgets('Dashboard shows profile and info cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DashboardApp());

    expect(find.text('AngelBoard'), findsOneWidget);
    expect(find.text('Angel Chelssa'), findsOneWidget);
    expect(find.text('Assignments'), findsOneWidget);
  });
}