import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weather_dashboard/main.dart';

void main() {
  testWidgets('App loads and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const WeatherApp());
    await tester.pump();

    expect(find.text('Weather Dashboard'), findsOneWidget);
  });
}
