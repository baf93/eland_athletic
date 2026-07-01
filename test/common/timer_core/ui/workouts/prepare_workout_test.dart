import 'package:eland_athletic/common/strings.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:eland_athletic/common/timer_core/ui/workouts/prepare_workout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_utils/test_app.dart';
import '../../../../test_utils/timer_state_factory.dart';

void main() {
  group('PrepareWorkoutWidget', () {
    testWidgets('renders countdown number and ready text', (tester) async {
      final state = timerStateForTest(timerType: TimerType.preparation, remainingSeconds: 5);

      await tester.pumpWidget(buildTestApp(PrepareWorkoutWidget(timerState: state)));

      expect(find.text('5'), findsOneWidget);
      expect(find.text(ElandStrings.of('get_ready').toUpperCase()), findsOneWidget);
    });

    testWidgets('renders landscape without throwing', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          PrepareWorkoutWidget(timerState: timerStateForTest(timerType: TimerType.preparation, remainingSeconds: 5)),
          size: const Size(844, 390),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
