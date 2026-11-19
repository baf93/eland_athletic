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

/// Summary shown at the top of the history page.
class HistoryStats {
  final int workoutsThisWeek;
  final int secondsThisWeek;
  final int totalWorkouts;

  /// Consecutive days (ending today or yesterday) with at least one workout.
  final int dayStreak;

  /// Consecutive ISO weeks (ending this week or the previous one) with at
  /// least one workout.
  final int weekStreak;

  const HistoryStats({
    required this.workoutsThisWeek,
    required this.secondsThisWeek,
    required this.totalWorkouts,
    required this.dayStreak,
    required this.weekStreak,
  });

  factory HistoryStats.from(List<WorkoutLog> logs, {DateTime? now}) {
    final today = day(now ?? DateTime.now());
    final thisWeek = weekStart(today);

    var count = 0;
    var seconds = 0;
    final days = <DateTime>{};
    final weeks = <DateTime>{};
    for (final log in logs) {
      final d = day(log.completedAt);
      days.add(d);
      weeks.add(weekStart(d));
      if (!d.isBefore(thisWeek)) {
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

    var weekStreak = 0;
    var week = weeks.contains(thisWeek)
        ? thisWeek
        : DateTime(thisWeek.year, thisWeek.month, thisWeek.day - 7);
    while (weeks.contains(week)) {
      weekStreak++;
      week = DateTime(week.year, week.month, week.day - 7);
    }

    return HistoryStats(
      workoutsThisWeek: count,
      secondsThisWeek: seconds,
      totalWorkouts: logs.length,
      dayStreak: streak,
      weekStreak: weekStreak,
    );
  }

  // Calendar arithmetic (not Duration) so DST changes do not shift days.
  static DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime weekStart(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - 1));
}

/// Totals for one calendar month.
class MonthStats {
  final int sessions;
  final int seconds;

  /// Days of the month (1-31) with at least one workout.
  final Set<int> activeDays;

  const MonthStats(this.sessions, this.seconds, this.activeDays);

  factory MonthStats.from(List<WorkoutLog> logs, int year, int month) {
    var sessions = 0;
    var seconds = 0;
    final days = <int>{};
    for (final log in logs) {
      final d = log.completedAt;
      if (d.year != year || d.month != month) continue;
      sessions++;
      seconds += log.activeSeconds;
      days.add(d.day);
    }
    return MonthStats(sessions, seconds, days);
  }
}

/// Ids of the logs holding a personal best of a saved workout: most AMRAP
/// rounds, fastest For Time within the cap. Only workouts done at least twice
/// count, otherwise every first session would be a "record".
Set<String> personalBestIds(List<WorkoutLog> logs) {
  final byWorkout = <String, List<WorkoutLog>>{};
  for (final log in logs) {
    // Quick timers change settings every time: results are not comparable.
    if (log.workoutId.isEmpty || log.workoutId.endsWith('_qt')) continue;
    byWorkout.putIfAbsent(log.workoutId, () => []).add(log);
  }

  final ids = <String>{};
  for (final group in byWorkout.values) {
    if (group.length < 2) continue;

    WorkoutLog? bestAmrap;
    for (final log in group) {
      final rounds = log.amrapRounds;
      if (rounds == null) continue;
      if (bestAmrap == null || rounds > bestAmrap.amrapRounds!) bestAmrap = log;
    }
    if (bestAmrap != null) ids.add(bestAmrap.id);

    WorkoutLog? bestTime;
    int? bestSeconds;
    for (final log in group) {
      final valid = log.forTimeResults.where((r) => !r.overCap).toList();
      if (valid.isEmpty || valid.length != log.forTimeResults.length) continue;
      final total = valid.fold<int>(0, (s, r) => s + r.seconds);
      if (bestSeconds == null || total < bestSeconds) {
        bestSeconds = total;
        bestTime = log;
      }
    }
    if (bestTime != null) ids.add(bestTime.id);
  }
  return ids;
}
