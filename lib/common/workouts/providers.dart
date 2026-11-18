import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';
import 'reminder_service.dart';
import 'workout_repository.dart';

final workoutRepositoryProvider =
    Provider<WorkoutRepository>((ref) => WorkoutRepository());

final reminderSchedulerProvider =
    Provider<ReminderScheduler>((ref) => ReminderService.instance);

class CustomWorkoutsNotifier extends AsyncNotifier<List<CustomWorkout>> {
  WorkoutRepository get _repo => ref.read(workoutRepositoryProvider);
  ReminderScheduler get _reminders => ref.read(reminderSchedulerProvider);

  @override
  Future<List<CustomWorkout>> build() => _repo.getWorkouts();

  Future<void> save(CustomWorkout workout) async {
    await _repo.saveWorkout(workout);
    await _reminders.schedule(workout);
    state = AsyncData(await _repo.getWorkouts());
  }

  Future<void> delete(String id) async {
    await _repo.deleteWorkout(id);
    await _reminders.cancel(id);
    state = AsyncData(await _repo.getWorkouts());
  }

  Future<void> reload() async {
    state = AsyncData(await _repo.getWorkouts());
  }
}

final customWorkoutsProvider =
    AsyncNotifierProvider<CustomWorkoutsNotifier, List<CustomWorkout>>(
        CustomWorkoutsNotifier.new);

class HistoryNotifier extends AsyncNotifier<List<WorkoutLog>> {
  WorkoutRepository get _repo => ref.read(workoutRepositoryProvider);

  @override
  Future<List<WorkoutLog>> build() => _repo.getHistory();

  Future<void> add(WorkoutLog log) async {
    await _repo.saveLog(log);
    state = AsyncData(await _repo.getHistory());
  }

  Future<void> delete(String id) async {
    await _repo.deleteLog(id);
    state = AsyncData(await _repo.getHistory());
  }

  Future<void> reload() async {
    state = AsyncData(await _repo.getHistory());
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<WorkoutLog>>(
        HistoryNotifier.new);

/// Weekly summary shown at the top of the history page.
class HistoryStats {
  final int workoutsThisWeek;
  final int secondsThisWeek;
  final int totalWorkouts;

  /// Consecutive days (ending today or yesterday) with at least one workout.
  final int dayStreak;

  const HistoryStats({
    required this.workoutsThisWeek,
    required this.secondsThisWeek,
    required this.totalWorkouts,
    required this.dayStreak,
  });

  factory HistoryStats.from(List<WorkoutLog> logs, {DateTime? now}) {
    final today = _day(now ?? DateTime.now());
    // Calendar arithmetic (not Duration) so DST changes do not shift days.
    final weekStart =
        DateTime(today.year, today.month, today.day - (today.weekday - 1));

    var count = 0;
    var seconds = 0;
    final days = <DateTime>{};
    for (final log in logs) {
      final day = _day(log.completedAt);
      days.add(day);
      if (!day.isBefore(weekStart)) {
        count++;
        seconds += log.activeSeconds;
      }
    }

    var streak = 0;
    var cursor = days.contains(today)
        ? today
        : DateTime(today.year, today.month, today.day - 1);
    while (days.contains(cursor)) {
      streak++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }

    return HistoryStats(
      workoutsThisWeek: count,
      secondsThisWeek: seconds,
      totalWorkouts: logs.length,
      dayStreak: streak,
    );
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
}
