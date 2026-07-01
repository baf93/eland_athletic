import 'package:eland_athletic/common/strings.dart';
import 'package:eland_athletic/common/timer_core/models/timer_state.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:eland_athletic/common/timer_core/models/workout_phase_summary.dart';
import 'package:eland_athletic/common/widgets/phase_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/test_app.dart';

TimerState phaseState({
  int currentPhaseIndex = 0,
  String? notes,
}) {
  return TimerState.initial().copyWith(
    isLoading: false,
    status: TimerStatus.running,
    timerType: TimerType.tabata,
    currentIntervalNotes: notes,
    currentPhaseIndex: currentPhaseIndex,
    totalPhases: 2,
    workoutPhaseSummary: const [
      WorkoutPhaseSummary(title: 'WORK', details: '20s'),
      WorkoutPhaseSummary(title: 'REST', details: '10s'),
    ],
  );
}

void main() {
  setUpAll(() => ElandStrings.initLocale('en'));

  group('PhaseBar', () {
    testWidgets('renders next phase and phase counter', (tester) async {
      await tester.pumpWidget(buildTestApp(PhaseBar(timerState: phaseState(), onTap: () {})));

      expect(find.text(ElandStrings.of('next').toUpperCase()), findsOneWidget);
      expect(find.text('WORK'), findsOneWidget);
      expect(find.text('[ 0/2 ]'), findsOneWidget);
      expect(find.byIcon(Icons.notes_rounded), findsOneWidget);
    });

    testWidgets('renders completion fallback when there is no next phase', (tester) async {
      await tester.pumpWidget(
        buildTestApp(PhaseBar(timerState: phaseState(currentPhaseIndex: 2), onTap: () {})),
      );

      expect(find.text(ElandStrings.of('phase_complete').toUpperCase()), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var taps = 0;

      await tester.pumpWidget(buildTestApp(PhaseBar(timerState: phaseState(), onTap: () => taps++)));

      await tester.tap(find.byType(PhaseBar));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('does not throw with long phase names', (tester) async {
      final state = TimerState.initial().copyWith(
        isLoading: false,
        currentPhaseIndex: 0,
        totalPhases: 1,
        workoutPhaseSummary: const [
          WorkoutPhaseSummary(title: 'VERY VERY VERY LONG PHASE TITLE', details: '20s'),
        ],
      );

      await tester.pumpWidget(
        buildTestApp(PhaseBar(timerState: state, onTap: () {}), size: const Size(320, 640)),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
