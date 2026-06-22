import 'timercore_enums.dart';
import 'workout_phase_summary.dart';

class TimerState {
  final int remainingSeconds;
  final TimerStatus status;
  final String currentIntervalTitle;
  final String? currentIntervalNotes;
  final IntervalType intervalType;
  final TimerType timerType;
  final List<WorkoutPhaseSummary> workoutPhaseSummary;
  final int currentPhaseIndex;
  final int totalPhases;
  final String workoutTitle;
  final bool isLastPhase;
  final double intervalProgress;
  final String workoutId;

  const TimerState({
    required this.remainingSeconds,
    required this.status,
    required this.currentIntervalTitle,
    this.currentIntervalNotes,
    required this.intervalType,
    required this.timerType,
    required this.workoutPhaseSummary,
    required this.currentPhaseIndex,
    required this.totalPhases,
    required this.workoutTitle,
    required this.isLastPhase,
    required this.intervalProgress,
    required this.workoutId,
  });

  factory TimerState.initial() {
    return const TimerState(
      remainingSeconds: 0,
      status: TimerStatus.paused,
      currentIntervalTitle: '',
      currentIntervalNotes: null,
      intervalType: IntervalType.work,
      timerType: TimerType.preparation,
      workoutPhaseSummary: [],
      currentPhaseIndex: 0,
      totalPhases: 0,
      workoutTitle: '',
      isLastPhase: false,
      intervalProgress: 0,
      workoutId: '',
    );
  }

  TimerState copyWith({
    int? remainingSeconds,
    TimerStatus? status,
    String? currentIntervalTitle,
    String? currentIntervalNotes,
    IntervalType? intervalType,
    TimerType? timerType,
    List<WorkoutPhaseSummary>? workoutPhaseSummary,
    int? currentPhaseIndex,
    int? totalPhases,
    String? workoutTitle,
    bool? isLastPhase,
    double? intervalProgress,
    String? workoutId,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      currentIntervalTitle: currentIntervalTitle ?? this.currentIntervalTitle,
      currentIntervalNotes: currentIntervalNotes ?? this.currentIntervalNotes,
      intervalType: intervalType ?? this.intervalType,
      timerType: timerType ?? this.timerType,
      workoutPhaseSummary: workoutPhaseSummary ?? this.workoutPhaseSummary,
      currentPhaseIndex: currentPhaseIndex ?? this.currentPhaseIndex,
      totalPhases: totalPhases ?? this.totalPhases,
      workoutTitle: workoutTitle ?? this.workoutTitle,
      isLastPhase: isLastPhase ?? this.isLastPhase,
      intervalProgress: intervalProgress ?? this.intervalProgress,
      workoutId: workoutId ?? this.workoutId,
    );
  }
}