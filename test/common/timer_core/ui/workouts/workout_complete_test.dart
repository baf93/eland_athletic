import 'package:eland_athletic/common/strings.dart';
import 'package:eland_athletic/common/timer_core/ui/workouts/workout_complete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_utils/test_app.dart';

void main() {
  group('WorkoutCompleteWidget', () {
    testWidgets('renders completion icon and message', (tester) async {
      await tester.pumpWidget(buildTestApp(const WorkoutCompleteWidget()));

      expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
      expect(find.text(ElandStrings.of('great_job').toUpperCase()), findsOneWidget);
    });

    testWidgets('renders landscape without throwing', (tester) async {
      await tester.pumpWidget(buildTestApp(const WorkoutCompleteWidget(), size: const Size(844, 390)));

      expect(tester.takeException(), isNull);
    });
  });
}
