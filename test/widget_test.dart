import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_care_water_reminder/main.dart';

void main() {
  testWidgets('Verify Plant Care app title',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(
      find.text('Plant Care Community'),
      findsOneWidget,
    );
  });

  testWidgets('Verify app has a Scaffold',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(
      find.byType(Scaffold),
      findsOneWidget,
    );
  });
}
