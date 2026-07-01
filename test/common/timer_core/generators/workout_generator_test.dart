import 'package:eland_athletic/common/strings.dart';
import 'package:eland_athletic/common/timer_core/generators/workout_generator.dart';
import 'package:eland_athletic/common/timer_core/models/interval_audio_haptic_config.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:eland_athletic/common/timer_core/models/workout_config.dart';
import 'package:flutter_test/flutter_test.dart';

List<List<IntervalAudioConfig>> audio(int count) =>
    List.generate(count, (_) => <IntervalAudioConfig>[]);
List<List<IntervalHapticConfig>> haptic(int count) =>
    List.generate(count, (_) => <IntervalHapticConfig>[]);

void main() {
  setUpAll(() => ElandStrings.initLocale('en'));

  group('WorkoutGenerator', () {
    final generator = WorkoutGenerator();

    test('handles empty config list', () {
      expect(generator.generate([]), isEmpty);
      expect(generator.generateUIPhaseSummary([]), isEmpty);
    });

    test('generates UI summary from config metadata', () {
      final configs = [
        AMRAPConfig(
          totalMinutes: 10,
          totalSeconds: 0,
          phaseTitle: 'AMRAP',
          phaseSetting: '10M',
          workoutTitle: 'Workout',
          workoutId: 'amrap_qt',
          audioConfigs: audio(1),
          hapticConfigs: haptic(1),
        ),
        RestConfig(
          totalMinutes: 1,
          totalSeconds: 0,
          phaseTitle: 'REST',
          phaseSetting: '1M',
          workoutTitle: 'Workout',
          workoutId: 'rest_qt',
          audioConfigs: audio(1),
          hapticConfigs: haptic(1),
        ),
      ];

      final summary = generator.generateUIPhaseSummary(configs);

      expect(summary, hasLength(2));
      expect(summary[0].title, 'AMRAP');
      expect(summary[0].details, '10M');
      expect(summary[1].title, 'REST');
      expect(summary[1].details, '1M');
    });

    test('concatenates generated intervals and assigns phase metadata', () {
      final configs = [
        CountdownConfig(
          totalMinutes: 1,
          totalSeconds: 0,
          phaseTitle: 'COUNTDOWN',
          phaseSetting: '1M',
          workoutTitle: 'Workout',
          workoutId: 'countdown_qt',
          audioConfigs: audio(1),
          hapticConfigs: haptic(1),
        ),
        EMOMConfig(
          roundDuration: 60,
          totalMinutes: 3,
          phaseTitle: 'EMOM',
          phaseSetting: '3M',
          workoutTitle: 'Workout',
          workoutId: 'emom_qt',
          audioConfigs: audio(3),
          hapticConfigs: haptic(3),
        ),
      ];

      final workout = generator.generate(configs);

      expect(workout, hasLength(4));
      expect(workout.first.sourcePhase, TimerType.countdown);
      expect(workout.first.currentPhase, 1);
      expect(workout.first.totalPhases, 2);

      expect(workout[1].sourcePhase, TimerType.emom);
      expect(workout[1].currentPhase, 2);
      expect(workout.last.currentRound, 3);
      expect(workout.every((i) => i.totalPhases == 2), isTrue);
    });
  });
}
