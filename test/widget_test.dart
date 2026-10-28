import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_care_water_reminder/main.dart';

void main() {
  testWidgets('Plant Care app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const PlantCareApp());
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
