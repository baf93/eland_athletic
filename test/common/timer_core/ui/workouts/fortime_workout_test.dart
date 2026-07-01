import 'package:eland_athletic/common/strings.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:eland_athletic/common/timer_core/ui/workouts/fortime_workout.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_utils/test_app.dart';
import '../../../../test_utils/timer_state_factory.dart';

void main() {
  group('FortimeWorkoutWidget', () {
    testWidgets('renders normal for-time state', (tester) async {
      final state = timerStateForTest(timerType: TimerType.fortime, remainingSeconds: 120);

      await tester.pumpWidget(buildTestApp(FortimeWorkoutWidget(timerState: state)));

      expect(find.text(ElandStrings.of('timer_fortime').toUpperCase()), findsOneWidget);
      expect(find.text('02:00'), findsOneWidget);
    });

    testWidgets('renders paused state without relying on hint copy', (tester) async {
      final state = timerStateForTest(
        timerType: TimerType.fortime,
        status: TimerStatus.paused,
        remainingSeconds: 120,
      );

      await tester.pumpWidget(buildTestApp(FortimeWorkoutWidget(timerState: state)));

      expect(find.text(ElandStrings.of('paused').toUpperCase()), findsOneWidget);
      expect(find.text('02:00'), findsOneWidget);
    });

    testWidgets('renders overtime with plus time and total time', (tester) async {
      final state = timerStateForTest(
        timerType: TimerType.fortime,
        remainingSeconds: -15,
        elapsedSeconds: 615,
        isOvertime: true,
      );

      await tester.pumpWidget(buildTestApp(FortimeWorkoutWidget(timerState: state)));

      expect(find.text(ElandStrings.of('overtime').toUpperCase()), findsOneWidget);
      expect(find.text('+00:15'), findsOneWidget);
      expect(find.text('10:15'), findsOneWidget);
    });
  });
}
