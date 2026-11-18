import 'package:eland_athletic/common/strings.dart';
import 'package:eland_athletic/common/theme.dart';
import 'package:eland_athletic/common/timer_core/models/timer_block.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:eland_athletic/common/workouts/models.dart';
import 'package:eland_athletic/common/workouts/providers.dart';
import 'package:eland_athletic/common/workouts/reminder_service.dart';
import 'package:eland_athletic/common/workouts/workout_repository.dart';
import 'package:eland_athletic/user_app/workouts/history_page.dart';
import 'package:eland_athletic/user_app/workouts/my_workouts_page.dart';
import 'package:eland_athletic/user_app/workouts/workout_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryRepository extends WorkoutRepository {
  final Map<String, CustomWorkout> workouts = {};
  final Map<String, WorkoutLog> logs = {};

  @override
  Future<List<CustomWorkout>> getWorkouts() async => workouts.values.toList();

  @override
  Future<void> saveWorkout(CustomWorkout workout) async =>
      workouts[workout.id] = workout;

  @override
  Future<void> deleteWorkout(String id) async => workouts.remove(id);

  @override
  Future<List<WorkoutLog>> getHistory() async => logs.values.toList()
    ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

  @override
  Future<void> saveLog(WorkoutLog log) async => logs[log.id] = log;

  @override
  Future<void> deleteLog(String id) async => logs.remove(id);
}

class _FakeReminders implements ReminderScheduler {
  final List<String> scheduled = [];
  final List<String> cancelled = [];

  @override
  Future<void> schedule(CustomWorkout workout) async =>
      scheduled.add(workout.id);

  @override
  Future<void> cancel(String workoutId) async => cancelled.add(workoutId);

  @override
  Future<void> rescheduleAll(List<CustomWorkout> workouts) async {}
}

Widget _app(Widget home, _MemoryRepository repo, _FakeReminders reminders) {
  ElandStrings.initLocale('en');
  return ProviderScope(
    overrides: [
      workoutRepositoryProvider.overrideWithValue(repo),
      reminderSchedulerProvider.overrideWithValue(reminders),
    ],
    child: MaterialApp(theme: ElandTheme.darkTheme, home: home),
  );
}

void main() {
  late _MemoryRepository repo;
  late _FakeReminders reminders;

  setUp(() {
    repo = _MemoryRepository();
    reminders = _FakeReminders();
  });

  testWidgets('empty state, then build and save a two-phase workout',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_app(const MyWorkoutsPage(), repo, reminders));
    await tester.pumpAndSettle();
    expect(find.textContaining('No saved workouts yet'), findsOneWidget);

    // New workout
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Leg day');

    // Phase 1: Tabata with defaults
    await tester.tap(find.text('ADD PHASE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TABATA'));
    await tester.pumpAndSettle();
    expect(find.textContaining('TOTAL TIME'), findsOneWidget);
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();

    // Phase 2: Rest
    await tester.tap(find.text('ADD PHASE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('REST'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();

    expect(find.text('PHASES (2)'), findsOneWidget);

    // Save the workout
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();

    expect(repo.workouts.length, 1);
    final saved = repo.workouts.values.single;
    expect(saved.name, 'Leg day');
    expect(saved.blocks.map((b) => b.type),
        [TimerType.tabata, TimerType.rest]);
    expect(reminders.scheduled, [saved.id]);

    // Back on the list
    expect(find.text('LEG DAY'), findsOneWidget);
    expect(find.textContaining('2 phases'), findsOneWidget);
  });

  testWidgets('editor refuses to save without a name', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_app(const MyWorkoutsPage(), repo, reminders));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();

    expect(find.text('Give your workout a name'), findsOneWidget);
    expect(repo.workouts, isEmpty);
  });

  testWidgets('detail page shows phases, notes and reminder', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final workout = CustomWorkout.create(
      name: 'Engine',
      blocks: [
        TimerBlock.defaultsFor(TimerType.emom)
            .copyWith(name: 'Row', notes: '12 cal'),
      ],
    ).copyWith(
      reminder: const WorkoutReminder(weekdays: [1, 4], hour: 7, minute: 15),
    );
    repo.workouts[workout.id] = workout;

    await tester.pumpWidget(
        _app(WorkoutDetailPage(workoutId: workout.id), repo, reminders));
    await tester.pumpAndSettle();

    expect(find.text('ENGINE'), findsOneWidget);
    expect(find.text('ROW'), findsOneWidget);
    expect(find.text('12 cal'), findsOneWidget);
    expect(find.text('MON THU · 07:15'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
  });

  testWidgets('history shows weekly stats and results', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime.now();
    repo.logs['a'] = WorkoutLog(
      id: 'a',
      workoutId: 'amrap_qt',
      title: 'AMRAP',
      completedAt: now,
      activeSeconds: 720,
      phases: const ['AMRAP · 12:00'],
      amrapRounds: 6,
    );

    await tester.pumpWidget(_app(const HistoryPage(), repo, reminders));
    await tester.pumpAndSettle();

    expect(find.text('THIS WEEK'), findsOneWidget);
    expect(find.text('12'), findsOneWidget); // minutes
    expect(find.text('6 ROUNDS'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
  });
}
