import 'workout_lap.dart';

enum TimerStatus { idle, running, paused, completed }

class TimerState {
  final int remainingSeconds;
  final int elapsedSeconds;
  final int currentIntervalIndex;
  final int totalIntervals;
  final TimerStatus status;
  final String currentIntervalTitle;
  final String? currentIntervalNotes;
  final List<WorkoutLap> laps;

  const TimerState({
    required this.remainingSeconds,
    required this.elapsedSeconds,
    required this.currentIntervalIndex,
    required this.totalIntervals,
    required this.status,
    required this.currentIntervalTitle,
    this.currentIntervalNotes,
    this.laps = const [],
  });

  factory TimerState.initial() {
    return const TimerState(
      remainingSeconds: 0,
      elapsedSeconds: 0,
      currentIntervalIndex: 0,
      totalIntervals: 0,
      status: TimerStatus.idle,
      currentIntervalTitle: '',
      currentIntervalNotes: null,
      laps: [],
    );
  }

  TimerState copyWith({
    int? remainingSeconds,
    int? elapsedSeconds,
    int? currentIntervalIndex,
    int? totalIntervals,
    TimerStatus? status,
    String? currentIntervalTitle,
    String? currentIntervalNotes,
    List<WorkoutLap>? laps,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      currentIntervalIndex: currentIntervalIndex ?? this.currentIntervalIndex,
      totalIntervals: totalIntervals ?? this.totalIntervals,
      status: status ?? this.status,
      currentIntervalTitle: currentIntervalTitle ?? this.currentIntervalTitle,
      currentIntervalNotes: currentIntervalNotes ?? this.currentIntervalNotes,
      laps: laps ?? this.laps,
    );
  }
}