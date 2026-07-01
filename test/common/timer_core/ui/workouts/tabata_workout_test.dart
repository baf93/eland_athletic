import 'package:eland_athletic/common/strings.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:eland_athletic/common/timer_core/ui/workouts/tabata_workout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_utils/test_app.dart';
import '../../../../test_utils/timer_state_factory.dart';

void main() {
  group('TabataWorkoutWidget', () {
    testWidgets('renders work state time and counters', (tester) async {
      final state = timerStateForTest(
        timerType: TimerType.tabata,
        intervalType: IntervalType.work,
        remainingSeconds: 20,
      );

      await tester.pumpWidget(buildTestApp(TabataWorkoutWidget(timerState: state)));

      expect(find.text('00:20'), findsOneWidget);
      expect(find.textContaining('2/8'), findsWidgets);
      expect(find.textContaining('1/3'), findsWidgets);
    });

    testWidgets('renders rest state without throwing', (tester) async {
      final state = timerStateForTest(
        timerType: TimerType.tabata,
        intervalType: IntervalType.rest,
        remainingSeconds: 10,
      );

      await tester.pumpWidget(buildTestApp(TabataWorkoutWidget(timerState: state)));

      expect(find.text('00:10'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cooldown state and landscape without throwing', (tester) async {
      final state = timerStateForTest(
        timerType: TimerType.tabata,
        intervalType: IntervalType.cooldown,
        remainingSeconds: 60,
      );

      await tester.pumpWidget(
        buildTestApp(TabataWorkoutWidget(timerState: state), size: const Size(844, 390)),
      );

      expect(find.text('01:00'), findsOneWidget);
      expect(find.text(ElandStrings.of('cooldown_time').toUpperCase()), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
