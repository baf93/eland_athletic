import 'package:eland_athletic/common/strings.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:eland_athletic/common/timer_core/ui/workouts/rest_workout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_utils/test_app.dart';
import '../../../../test_utils/timer_state_factory.dart';

void main() {
  group('RestWorkoutWidget', () {
    testWidgets('renders rest title and time', (tester) async {
      final state = timerStateForTest(timerType: TimerType.rest, intervalType: IntervalType.rest, remainingSeconds: 75);

      await tester.pumpWidget(buildTestApp(RestWorkoutWidget(timerState: state)));

      expect(find.text(ElandStrings.of('timer_rest').toUpperCase()), findsOneWidget);
      expect(find.text('01:15'), findsOneWidget);
    });

    testWidgets('renders landscape without throwing', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          RestWorkoutWidget(timerState: timerStateForTest(timerType: TimerType.rest, intervalType: IntervalType.rest)),
          size: const Size(844, 390),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
