import 'package:eland_athletic/common/strings.dart';
import 'package:eland_athletic/common/timer_core/generators/workout_generator.dart';
import 'package:eland_athletic/common/timer_core/models/timer_block.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => ElandStrings.initLocale('en'));

  group('TimerBlock.totalSeconds', () {
    test('tabata total matches the intervals the engine really runs', () {
      const block = TimerBlock(type: TimerType.tabata, params: {
        'work': 20,
        'rest': 10,
        'rounds': 8,
        'sets': 3,
        'setRest': 60,
      });

      final config = block.toConfig(workoutId: 'w', workoutTitle: 'W');
      final intervals = config.toIntervals(1, 1);
      final engineTotal =
          intervals.fold<int>(0, (sum, i) => sum + i.durationSeconds);

      // 20*24 + 10*7*3 + 60*2 = 810s (13:30). The old page showed 14 min.
      expect(block.totalSeconds, 810);
      expect(block.totalSeconds, engineTotal);
    });

    test('emom, amrap, countdown and rest durations', () {
      expect(
        const TimerBlock(
                type: TimerType.emom,
                params: {'roundSeconds': 45, 'rounds': 12})
            .totalSeconds,
        540,
      );
      expect(
        const TimerBlock(
                type: TimerType.amrap, params: {'minutes': 12, 'seconds': 30})
            .totalSeconds,
        750,
      );
      expect(TimerBlock.defaultsFor(TimerType.countdown).totalSeconds, 300);
      expect(TimerBlock.defaultsFor(TimerType.rest).totalSeconds, 60);
    });

    test('missing params fall back to defaults', () {
      const block = TimerBlock(type: TimerType.emom, params: {'rounds': 5});
      expect(block.param('roundSeconds'), 60);
      expect(block.totalSeconds, 300);
    });
  });

  group('TimerBlock validity', () {
    test('a zero-length block is invalid', () {
      const block = TimerBlock(
          type: TimerType.amrap, params: {'minutes': 0, 'seconds': 0});
      expect(block.isValid, isFalse);
    });

    test('defaults are valid for every editable type', () {
      for (final type in TimerBlock.editableTypes) {
        expect(TimerBlock.defaultsFor(type).isValid, isTrue, reason: '$type');
      }
    });

    test('every editable type exposes its editor fields', () {
      for (final type in TimerBlock.editableTypes) {
        final fields = TimerBlock.fieldsFor(type);
        expect(fields, isNotEmpty);
        for (final f in fields) {
          expect(TimerBlock.defaults[type]!.containsKey(f.key), isTrue,
              reason: '$type.${f.key}');
        }
      }
    });
  });

  group('TimerBlock.toConfig', () {
    test('name and notes reach the generated intervals', () {
      const block = TimerBlock(
        type: TimerType.amrap,
        params: {'minutes': 8, 'seconds': 0},
        name: 'Chipper',
        notes: '10 burpees + 15 swings',
      );
      final configs = [block.toConfig(workoutId: 'id', workoutTitle: 'LEGS')];
      final generator = WorkoutGenerator();
      final intervals = generator.generate(configs);
      final summary = generator.generateUIPhaseSummary(configs);

      expect(intervals.single.title, 'AMRAP');
      expect(intervals.single.notes, '10 burpees + 15 swings');
      expect(intervals.single.workoutTitle, 'LEGS');
      expect(summary.single.title, 'CHIPPER');
      expect(summary.single.details, '08:00');
    });

    test('blank notes are not shown', () {
      const block = TimerBlock(
          type: TimerType.countdown,
          params: {'minutes': 1, 'seconds': 0},
          notes: '   ');
      final interval = block
          .toConfig(workoutId: 'id', workoutTitle: 'T')
          .toIntervals(1, 1)
          .single;
      expect(interval.notes, isNull);
    });

    test('tabata cues: round voice, last round and final whistle', () {
      const block = TimerBlock(type: TimerType.tabata, params: {
        'work': 20,
        'rest': 10,
        'rounds': 3,
        'sets': 1,
        'setRest': 60,
      });
      final intervals = block
          .toConfig(workoutId: 'id', workoutTitle: 'T')
          .toIntervals(1, 1);

      List<String> startFiles(int i) => intervals[i]
          .audioConfig
          .where((a) => a.audioTrigger == AudioHapticTrigger.start)
          .map((a) => a.fileName)
          .toList();

      expect(intervals.length, 5); // W R W R W
      expect(startFiles(0), ['go.m4a']);
      expect(startFiles(1), ['rest.m4a']);
      expect(startFiles(2), ['round2.m4a']);
      expect(startFiles(4), ['last_round.m4a']);
      expect(
        intervals.last.audioConfig
            .any((a) => a.audioTrigger == AudioHapticTrigger.end),
        isTrue,
      );
    });

    test('for time has an overtime cue', () {
      final interval = TimerBlock.defaultsFor(TimerType.fortime)
          .toConfig(workoutId: 'id', workoutTitle: 'T')
          .toIntervals(1, 1)
          .single;
      expect(
        interval.audioConfig
            .any((a) => a.audioTrigger == AudioHapticTrigger.overtime),
        isTrue,
      );
    });
  });

  test('json round trip', () {
    const block = TimerBlock(
      type: TimerType.emom,
      params: {'roundSeconds': 40, 'rounds': 9},
      name: 'Cardio',
      notes: 'Row 12 cal',
    );
    final copy = TimerBlock.fromJson(block.toJson());
    expect(copy.type, TimerType.emom);
    expect(copy.params, block.params);
    expect(copy.name, 'Cardio');
    expect(copy.notes, 'Row 12 cal');
  });

  test('formatDuration', () {
    expect(TimerBlock.formatDuration(0), '00:00');
    expect(TimerBlock.formatDuration(810), '13:30');
    expect(TimerBlock.formatDuration(3725), '1:02:05');
  });
}
