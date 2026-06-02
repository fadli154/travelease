import 'package:flutter/material.dart';
import 'package:travelease/models/destination_model.dart';
import 'package:travelease/screens/home/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home screen renders empty state', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          destinationsStream: Stream<List<DestinationModel>>.value(const []),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('TravelEase'), findsOneWidget);
    expect(find.text('No destinations available yet.'), findsOneWidget);
  });
}
