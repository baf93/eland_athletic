import 'package:eland_athletic/common/timer_core/models/timer_block.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:eland_athletic/common/workouts/models.dart';
import 'package:eland_athletic/common/workouts/providers.dart';
import 'package:eland_athletic/common/workouts/reminder_service.dart';
import 'package:eland_athletic/common/workouts/workout_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

CustomWorkout _workout(String name, {WorkoutReminder? reminder}) {
  final w = CustomWorkout.create(
    name: name,
    blocks: [
      TimerBlock.defaultsFor(TimerType.tabata),
      const TimerBlock(
          type: TimerType.rest, params: {'minutes': 2, 'seconds': 0}),
      TimerBlock.defaultsFor(TimerType.amrap).copyWith(notes: '5 pull ups'),
    ],
  );
  return reminder == null ? w : w.copyWith(reminder: reminder);
}

WorkoutLog _log(String id, DateTime at, {int seconds = 600}) => WorkoutLog(
      id: id,
      workoutId: 'w1',
      title: 'LEGS',
      completedAt: at,
      activeSeconds: seconds,
      phases: const ['TABATA · 20s/10s · 8 R'],
    );

void main() {
  group('models', () {
    test('custom workout json round trip', () {
      final w = _workout('Legs',
          reminder: const WorkoutReminder(weekdays: [1, 3, 5], hour: 7));
      final copy = CustomWorkout.fromJson(w.toJson());

      expect(copy.id, w.id);
      expect(copy.name, 'Legs');
      expect(copy.blocks.length, 3);
      expect(copy.blocks[2].notes, '5 pull ups');
      expect(copy.totalSeconds, w.totalSeconds);
      expect(copy.reminder!.weekdays, [1, 3, 5]);
      expect(copy.reminder!.timeLabel, '07:00');
      expect(copy.toConfigs().length, 3);
    });

    test('reminder json is sanitized', () {
      final r = WorkoutReminder.fromJson({
        'weekdays': [5, 9, 1, 1, 0],
        'hour': 30,
        'minute': -4,
      });
      expect(r.weekdays, [1, 5]);
      expect(r.hour, 23);
      expect(r.minute, 0);
      expect(const WorkoutReminder(weekdays: []).isActive, isFalse);
    });

    test('workout validity', () {
      expect(_workout('A').isValid, isTrue);
      expect(_workout('  ').isValid, isFalse);
      expect(CustomWorkout.create(name: 'Empty', blocks: []).isValid, isFalse);
    });

    test('workout log json round trip with results', () {
      final log = WorkoutLog(
        id: 'l1',
        workoutId: 'fortime_qt',
        title: 'FOR TIME',
        completedAt: DateTime(2026, 11, 18, 7, 30),
        activeSeconds: 512,
        amrapRounds: 7,
        forTimeResults: const [
          ForTimeResult(title: 'FOR TIME', seconds: 610, capSeconds: 600),
        ],
      );
      final copy = WorkoutLog.fromJson(log.toJson());
      expect(copy.completedAt, log.completedAt);
      expect(copy.amrapRounds, 7);
      expect(copy.forTimeResults.single.overCap, isTrue);
    });
  });

  group('HistoryStats', () {
    test('week totals and day streak', () {
      final now = DateTime(2026, 11, 18, 20); // Wednesday
      final stats = HistoryStats.from([
        _log('a', DateTime(2026, 11, 18, 8), seconds: 600),
        _log('b', DateTime(2026, 11, 17, 8), seconds: 1200),
        _log('c', DateTime(2026, 11, 16, 8), seconds: 300), // Monday
        _log('d', DateTime(2026, 11, 14, 8)), // last week, breaks streak
      ], now: now);

      expect(stats.workoutsThisWeek, 3);
      expect(stats.secondsThisWeek, 2100);
      expect(stats.dayStreak, 3);
      expect(stats.totalWorkouts, 4);
    });

    test('week streak counts consecutive weeks', () {
      final stats = HistoryStats.from([
        _log('a', DateTime(2026, 11, 17, 8)), // this week
        _log('b', DateTime(2026, 11, 10, 8)), // last week
        _log('c', DateTime(2026, 11, 3, 8)), // two weeks ago
        _log('d', DateTime(2026, 10, 20, 8)), // gap before
      ], now: DateTime(2026, 11, 18, 9));
      expect(stats.weekStreak, 3);
    });

    test('month stats and personal bests', () {
      final logs = [
        _log('a', DateTime(2026, 11, 18, 8), seconds: 600),
        _log('b', DateTime(2026, 11, 2, 8), seconds: 900),
        _log('c', DateTime(2026, 10, 30, 8), seconds: 300),
      ];
      final month = MonthStats.from(logs, 2026, 11);
      expect(month.sessions, 2);
      expect(month.seconds, 1500);
      expect(month.activeDays, {18, 2});

      WorkoutLog amrap(String id, int rounds, {String workout = 'w1'}) =>
          WorkoutLog(
            id: id,
            workoutId: workout,
            title: 'A',
            completedAt: DateTime(2026, 11, 1),
            activeSeconds: 600,
            amrapRounds: rounds,
          );
      expect(
        personalBestIds([amrap('x', 5), amrap('y', 7), amrap('z', 6)]),
        {'y'},
      );
      // A single session is not a record, quick timers never are.
      expect(personalBestIds([amrap('x', 5)]), isEmpty);
      expect(
        personalBestIds([
          amrap('x', 5, workout: 'amrap_qt'),
          amrap('y', 7, workout: 'amrap_qt'),
        ]),
        isEmpty,
      );
    });

    test('streak still counts when today is not done yet', () {
      final stats = HistoryStats.from([
        _log('a', DateTime(2026, 11, 17, 8)),
        _log('b', DateTime(2026, 11, 16, 8)),
      ], now: DateTime(2026, 11, 18, 9));
      expect(stats.dayStreak, 2);
    });
  });

  group('ReminderService', () {
    setUpAll(tzdata.initializeTimeZones);

    test('next instance is the next matching weekday in the future', () {
      final rome = tz.getLocation('Europe/Rome');
      final from = tz.TZDateTime(rome, 2026, 11, 18, 19, 0); // Wed 19:00

      final wedLater = ReminderService.nextInstance(3, 20, 0, from: from);
      expect(wedLater, tz.TZDateTime(rome, 2026, 11, 18, 20, 0));

      final wedEarlier = ReminderService.nextInstance(3, 18, 0, from: from);
      expect(wedEarlier, tz.TZDateTime(rome, 2026, 11, 25, 18, 0));

      final monday = ReminderService.nextInstance(1, 7, 30, from: from);
      expect(monday, tz.TZDateTime(rome, 2026, 11, 23, 7, 30));
    });

    test('notification ids are stable, distinct and above the timer id', () {
      final a1 = ReminderService.notificationIdFor('abc', 1);
      expect(ReminderService.notificationIdFor('abc', 1), a1);
      expect(ReminderService.notificationIdFor('abc', 2), isNot(a1));
      expect(ReminderService.notificationIdFor('xyz', 1), isNot(a1));
      expect(a1, greaterThanOrEqualTo(1000));
    });
  });

  group('WorkoutRepository', () {
    late WorkoutRepository repo;

    setUpAll(sqfliteFfiInit);
    setUp(() {
      repo = WorkoutRepository(
        factory: databaseFactoryFfiNoIsolate,
        path: inMemoryDatabasePath,
      );
    });
    tearDown(() => repo.close());

    test('save, update and delete workouts', () async {
      final w = _workout('Legs');
      await repo.saveWorkout(w);
      await repo.saveWorkout(w.copyWith(name: 'Legs v2'));

      final all = await repo.getWorkouts();
      expect(all.length, 1);
      expect(all.single.name, 'Legs v2');
      expect((await repo.getWorkout(w.id))!.blocks.length, 3);

      await repo.deleteWorkout(w.id);
      expect(await repo.getWorkouts(), isEmpty);
    });

    test('history is returned newest first', () async {
      await repo.saveLog(_log('old', DateTime(2026, 1, 1)));
      await repo.saveLog(_log('new', DateTime(2026, 6, 1)));
      final logs = await repo.getHistory();
      expect(logs.map((l) => l.id), ['new', 'old']);

      await repo.deleteLog('new');
      expect((await repo.getHistory()).single.id, 'old');
    });

    test('export then import restores everything', () async {
      final w = _workout('Legs',
          reminder: const WorkoutReminder(weekdays: [2], hour: 18));
      await repo.saveWorkout(w);
      await repo.saveLog(_log('l1', DateTime(2026, 11, 1)));
      final backup = await repo.exportData(settings: {'language': 'it'});

      final fresh = WorkoutRepository(
        factory: databaseFactoryFfiNoIsolate,
        path: inMemoryDatabasePath,
      );
      // in-memory databases are shared per path within a process: start clean
      await fresh.deleteWorkout(w.id);
      await fresh.deleteLog('l1');

      final result = await fresh.importData(backup);
      expect(result.workouts, 1);
      expect(result.logs, 1);
      expect(result.settings['language'], 'it');
      expect((await fresh.getWorkouts()).single.reminder!.weekdays, [2]);
      await fresh.close();
    });

    test('import rejects files that are not Eland backups', () async {
      expect(
        () => repo.importData({'format': 'something-else'}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => repo.importData({
          'format': WorkoutRepository.backupFormat,
          'version': WorkoutRepository.backupVersion + 1,
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
