import 'package:eland_athletic/common/timer_core/models/timer_state.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:eland_athletic/common/timer_core/models/workout_phase_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimerState', () {
    test('initial returns expected default state', () {
      final state = TimerState.initial();

      expect(state.remainingSeconds, 0);
      expect(state.elapsedSeconds, 0);
      expect(state.status, TimerStatus.paused);
      expect(state.intervalType, IntervalType.work);
      expect(state.timerType, TimerType.preparation);
      expect(state.workoutPhaseSummary, isEmpty);
      expect(state.currentRound, 1);
      expect(state.totalRound, 1);
      expect(state.isOvertime, isFalse);
      expect(state.isLoading, isTrue);
    });

    test('copyWith changes only provided fields', () {
      final base = TimerState.initial();

      final updated = base.copyWith(
        remainingSeconds: 45,
        elapsedSeconds: 15,
        status: TimerStatus.running,
        timerType: TimerType.tabata,
        intervalType: IntervalType.rest,
        workoutTitle: 'TABATA',
        workoutId: 'tabata_qt',
        isLoading: false,
      );

      expect(updated.remainingSeconds, 45);
      expect(updated.elapsedSeconds, 15);
      expect(updated.status, TimerStatus.running);
      expect(updated.timerType, TimerType.tabata);
      expect(updated.intervalType, IntervalType.rest);
      expect(updated.workoutTitle, 'TABATA');
      expect(updated.workoutId, 'tabata_qt');
      expect(updated.isLoading, isFalse);

      expect(updated.currentRound, base.currentRound);
      expect(updated.totalSet, base.totalSet);
    });

    test('copyWith supports phase summary metadata', () {
      const phases = [
        WorkoutPhaseSummary(title: 'WORK', details: '20s'),
        WorkoutPhaseSummary(title: 'REST', details: '10s'),
      ];

      final state = TimerState.initial().copyWith(
        workoutPhaseSummary: phases,
        currentPhaseIndex: 1,
        totalPhases: 2,
        isLastPhase: true,
      );

      expect(state.workoutPhaseSummary, hasLength(2));
      expect(state.workoutPhaseSummary.first.title, 'WORK');
      expect(state.currentPhaseIndex, 1);
      expect(state.totalPhases, 2);
      expect(state.isLastPhase, isTrue);
    });
  });
}
