import 'workout_lap.dart';
import 'timer_enums.dart';
import 'workout_phase_summary.dart';

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

  final CountingDirection direction;
  final IntervalType intervalType;
  final TimerType timerType;

  final List<WorkoutPhaseSummary> workoutPhaseSummary;
  final int currentPhaseIndex;
  final int totalPhases;

  final String workoutTitle;
  final bool isLastPhase;
  final bool isLastInterval;
  final double intervalProgress;

  const TimerState({
    required this.remainingSeconds,
    required this.elapsedSeconds,
    required this.currentIntervalIndex,
    required this.totalIntervals,
    required this.status,
    required this.currentIntervalTitle,
    this.currentIntervalNotes,
    this.laps = const [],
    required this.direction,
    required this.intervalType,
    required this.timerType,
    required this.workoutPhaseSummary,
    required this.currentPhaseIndex,
    required this.totalPhases,
    required this.workoutTitle,
    required this.isLastPhase,
    required this.isLastInterval,
    required this.intervalProgress,
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
      direction: CountingDirection.down,
      intervalType: IntervalType.work,
      timerType: TimerType.preparation,
      workoutPhaseSummary: [],
      currentPhaseIndex: 0,
      totalPhases: 0,
      workoutTitle: '',
      isLastPhase: false,
      isLastInterval: false,
      intervalProgress: 0.0,
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
    CountingDirection? direction,
    IntervalType? intervalType,
    TimerType? timerType,
    List<WorkoutPhaseSummary>? workoutPhaseSummary,
    int? currentPhaseIndex,
    int? totalPhases,
    String? workoutTitle,
    bool? isLastPhase,
    bool? isLastInterval,
    double? intervalProgress,
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
      direction: direction ?? this.direction,
      intervalType: intervalType ?? this.intervalType,
      timerType: timerType ?? this.timerType,
      workoutPhaseSummary: workoutPhaseSummary ?? this.workoutPhaseSummary,
      currentPhaseIndex: currentPhaseIndex ?? this.currentPhaseIndex,
      totalPhases: totalPhases ?? this.totalPhases,
      workoutTitle: workoutTitle ?? this.workoutTitle,
      isLastPhase: isLastPhase ?? this.isLastPhase,
      isLastInterval: isLastInterval ?? this.isLastInterval,
      intervalProgress: intervalProgress ?? this.intervalProgress,
    );
  }
}