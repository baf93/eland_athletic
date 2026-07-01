import 'package:eland_athletic/common/strings.dart';
import 'package:eland_athletic/common/timer_core/models/interval_audio_haptic_config.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:eland_athletic/common/timer_core/models/workout_config.dart';
import 'package:flutter_test/flutter_test.dart';

List<List<IntervalAudioConfig>> audio(int count) {
  return List.generate(count, (_) => <IntervalAudioConfig>[]);
}

List<List<IntervalHapticConfig>> haptic(int count) {
  return List.generate(count, (_) => <IntervalHapticConfig>[]);
}

void main() {
  setUpAll(() => ElandStrings.initLocale('en'));

  group('WorkoutConfig implementations', () {
    test('AMRAPConfig creates one work interval with combined duration', () {
      final config = AMRAPConfig(
        totalMinutes: 12,
        totalSeconds: 30,
        phaseTitle: 'AMRAP',
        phaseSetting: '12M 30S',
        workoutTitle: 'AMRAP',
        workoutId: 'amrap_qt',
        audioConfigs: audio(1),
        hapticConfigs: haptic(1),
      );

      final intervals = config.toIntervals(1, 1);

      expect(intervals, hasLength(1));
      expect(intervals.single.durationSeconds, 750);
      expect(intervals.single.type, IntervalType.work);
      expect(intervals.single.sourcePhase, TimerType.amrap);
    });

    test('CountdownConfig creates one work interval with combined duration', () {
      final config = CountdownConfig(
        totalMinutes: 2,
        totalSeconds: 15,
        phaseTitle: 'COUNTDOWN',
        phaseSetting: '2M 15S',
        workoutTitle: 'COUNTDOWN',
        workoutId: 'countdown_qt',
        audioConfigs: audio(1),
        hapticConfigs: haptic(1),
      );

      expect(config.toIntervals(1, 1).single.durationSeconds, 135);
    });

    test('RestConfig creates one rest interval', () {
      final config = RestConfig(
        totalMinutes: 1,
        totalSeconds: 10,
        phaseTitle: 'REST',
        phaseSetting: '1M 10S',
        workoutTitle: 'REST',
        workoutId: 'rest_qt',
        audioConfigs: audio(1),
        hapticConfigs: haptic(1),
      );

      final interval = config.toIntervals(1, 1).single;

      expect(interval.durationSeconds, 70);
      expect(interval.type, IntervalType.rest);
      expect(interval.sourcePhase, TimerType.rest);
    });

    test('FortimeConfig creates one work interval', () {
      final config = FortimeConfig(
        totalMinutes: 5,
        totalSeconds: 45,
        phaseTitle: 'FOR TIME',
        phaseSetting: '5M 45S',
        workoutTitle: 'FOR TIME',
        workoutId: 'fortime_qt',
        audioConfigs: audio(1),
        hapticConfigs: haptic(1),
      );

      final interval = config.toIntervals(1, 1).single;

      expect(interval.durationSeconds, 345);
      expect(interval.type, IntervalType.work);
      expect(interval.sourcePhase, TimerType.fortime);
    });

    test('EMOMConfig creates one interval per minute and preserves rounds', () {
      final config = EMOMConfig(
        roundDuration: 60,
        totalMinutes: 10,
        phaseTitle: 'EMOM',
        phaseSetting: '10M',
        workoutTitle: 'EMOM',
        workoutId: 'emom_qt',
        audioConfigs: audio(10),
        hapticConfigs: haptic(10),
      );

      final intervals = config.toIntervals(1, 1);

      expect(intervals, hasLength(10));
      expect(intervals.first.currentRound, 1);
      expect(intervals.last.currentRound, 10);
      expect(intervals.every((i) => i.durationSeconds == 60), isTrue);
      expect(intervals.every((i) => i.totalRound == 10), isTrue);
    });

    test('TabataConfig creates alternating work and rest/cooldown intervals', () {
      const rounds = 4;
      const sets = 2;
      const totalIntervals = (rounds * sets * 2) - 1;

      final config = TabataConfig(
        workSeconds: 20,
        restSeconds: 10,
        roundsPerSet: rounds,
        totalSets: sets,
        restBetweenSets: 60,
        phaseTitle: 'TABATA',
        phaseSetting: '4R x 2S',
        workoutTitle: 'TABATA',
        workoutId: 'tabata_qt',
        audioConfigs: audio(totalIntervals),
        hapticConfigs: haptic(totalIntervals),
      );

      final intervals = config.toIntervals(1, 1);

      expect(intervals, hasLength(totalIntervals));
      expect(intervals.first.type, IntervalType.work);
      expect(intervals[1].type, IntervalType.rest);
      expect(intervals[7].type, IntervalType.cooldown);
      expect(intervals[7].durationSeconds, 60);
      expect(intervals.last.type, IntervalType.work);
      expect(intervals.last.currentSet, 2);
    });
  });
}
