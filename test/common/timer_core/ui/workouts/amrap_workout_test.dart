import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:eland_athletic/common/timer_core/ui/workouts/amrap_workout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_utils/test_app.dart';
import '../../../../test_utils/timer_state_factory.dart';

void main() {
  group('AmrapWorkoutWidget', () {
    testWidgets('renders time and round count', (tester) async {
      final notifier = ValueNotifier<int>(0);
      final state = timerStateForTest(timerType: TimerType.amrap, remainingSeconds: 600);

      await tester.pumpWidget(buildTestApp(AmrapWorkoutWidget(timerState: state, roundNotifier: notifier)));

      expect(find.text('10:00'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      notifier.dispose();
    });

    testWidgets('tap increments and remove decrements rounds', (tester) async {
      final notifier = ValueNotifier<int>(0);
      final state = timerStateForTest(timerType: TimerType.amrap, remainingSeconds: 600);

      await tester.pumpWidget(buildTestApp(AmrapWorkoutWidget(timerState: state, roundNotifier: notifier)));

      await tester.tap(find.text('0'));
      await tester.pump();
      expect(notifier.value, 1);

      await tester.tap(find.byIcon(Icons.undo));
      await tester.pump();
      expect(notifier.value, 0);

      notifier.dispose();
    });

    testWidgets('renders landscape without throwing', (tester) async {
      final notifier = ValueNotifier<int>(3);

      await tester.pumpWidget(
        buildTestApp(
          AmrapWorkoutWidget(
            timerState: timerStateForTest(timerType: TimerType.amrap, remainingSeconds: 120),
            roundNotifier: notifier,
          ),
          size: const Size(844, 390),
        ),
      );

      expect(tester.takeException(), isNull);
      notifier.dispose();
    });
  });
}
