import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:eland_athletic/common/timer_core/ui/workouts/countdown_workout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_utils/test_app.dart';
import '../../../../test_utils/timer_state_factory.dart';

void main() {
  group('CountdownWorkoutWidget', () {
    testWidgets('renders formatted remaining time and progress', (tester) async {
      final state = timerStateForTest(
        timerType: TimerType.countdown,
        remainingSeconds: 90,
        intervalProgress: 0.25,
      );

      await tester.pumpWidget(buildTestApp(CountdownWorkoutWidget(timerState: state)));

      expect(find.text('01:30'), findsOneWidget);
      final indicator = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
      expect(indicator.value, 0.75);
    });

    testWidgets('renders on landscape without throwing', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          CountdownWorkoutWidget(timerState: timerStateForTest(timerType: TimerType.countdown)),
          size: const Size(844, 390),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('01:30'), findsOneWidget);
    });
  });
}
