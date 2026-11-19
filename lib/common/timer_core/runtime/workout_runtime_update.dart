import 'eland_workout_runtime.dart';

class WorkoutRuntimeUpdate {
  final ElandWorkoutRuntimeStatus status;
  final String? workoutId;
  final String? workoutTitle;
  final int remainingSeconds;
  final int elapsedSeconds;
  final String? phaseTitle;
  final int currentRound;
  final int totalRound;
  final int currentSet;
  final int totalSet;
  final bool isOvertime;
  final double intervalProgress;

  const WorkoutRuntimeUpdate({
    required this.status,
    this.workoutId,
    this.workoutTitle,
    required this.remainingSeconds,
    required this.elapsedSeconds,
    this.phaseTitle,
    required this.currentRound,
    required this.totalRound,
    required this.currentSet,
    required this.totalSet,
    required this.isOvertime,
    required this.intervalProgress,
  });

  factory WorkoutRuntimeUpdate.fromMap(Map<dynamic, dynamic> map) {
    return WorkoutRuntimeUpdate(
      status: _statusFromString(map['status']?.toString()),
      workoutId: map['workoutId']?.toString(),
      workoutTitle: map['workoutTitle']?.toString(),
      remainingSeconds: (map['remainingSeconds'] as num?)?.toInt() ?? 0,
      elapsedSeconds: (map['elapsedSeconds'] as num?)?.toInt() ?? 0,
      phaseTitle: map['phaseTitle']?.toString(),
      currentRound: (map['currentRound'] as num?)?.toInt() ?? 1,
      totalRound: (map['totalRound'] as num?)?.toInt() ?? 1,
      currentSet: (map['currentSet'] as num?)?.toInt() ?? 1,
      totalSet: (map['totalSet'] as num?)?.toInt() ?? 1,
      isOvertime: map['isOvertime'] == true,
      intervalProgress: (map['intervalProgress'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'workoutId': workoutId,
      'workoutTitle': workoutTitle,
      'remainingSeconds': remainingSeconds,
      'elapsedSeconds': elapsedSeconds,
      'phaseTitle': phaseTitle,
      'currentRound': currentRound,
      'totalRound': totalRound,
      'currentSet': currentSet,
      'totalSet': totalSet,
      'isOvertime': isOvertime,
      'intervalProgress': intervalProgress,
    };
  }

  static ElandWorkoutRuntimeStatus _statusFromString(String? value) {
    switch (value) {
      case 'running':
        return ElandWorkoutRuntimeStatus.running;
      case 'paused':
        return ElandWorkoutRuntimeStatus.paused;
      case 'ended':
      case 'completed':
        return ElandWorkoutRuntimeStatus.ended;
      case 'idle':
      default:
        return ElandWorkoutRuntimeStatus.idle;
    }
  }
}