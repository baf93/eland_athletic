import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:eland_athletic/common/timer_core/ui/workouts/emom_workout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_utils/test_app.dart';
import '../../../../test_utils/timer_state_factory.dart';

void main() {
  group('EmomWorkoutWidget', () {
    testWidgets('renders round counter and time', (tester) async {
      final state = timerStateForTest(timerType: TimerType.emom, remainingSeconds: 60);

      await tester.pumpWidget(buildTestApp(EmomWorkoutWidget(timerState: state)));

      expect(find.text('2'), findsOneWidget);
      expect(find.text('/8'), findsOneWidget);
      expect(find.text('01:00'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders in landscape without throwing', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          EmomWorkoutWidget(timerState: timerStateForTest(timerType: TimerType.emom)),
          size: const Size(844, 390),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
