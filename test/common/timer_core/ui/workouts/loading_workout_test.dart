import 'package:eland_athletic/common/strings.dart';
import 'package:eland_athletic/common/timer_core/ui/workouts/loading_workout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() => ElandStrings.initLocale('en'));

  group('WorkoutLoadingPage', () {
    testWidgets('renders loading page', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WorkoutLoadingPage()));

      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(ElandStrings.of('loading_workout').toUpperCase()), findsOneWidget);
    });
  });
}
