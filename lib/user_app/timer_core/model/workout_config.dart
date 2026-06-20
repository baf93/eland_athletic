import 'workout_interval.dart';
import 'timer_enums.dart';

// --- DEFINIZIONE DELL'ENUM (Ora presente e visibile) ---


abstract class WorkoutConfig {
  final TimerType phaseType;
  const WorkoutConfig({required this.phaseType});

  /// Trasforma la configurazione in una lista di intervalli.
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases);
}

class EMOMConfig extends WorkoutConfig {
  final int totalMinutes;
  EMOMConfig({required this.totalMinutes}) : super(phaseType: TimerType.emom);

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases) {
    return List.generate(totalMinutes, (i) => WorkoutInterval(
      id: "emom_${DateTime.now().microsecondsSinceEpoch}_$i",
      title: "EMOM",
      durationSeconds: 60,
      type: IntervalType.work,
      sourcePhase: phaseType,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      currentRound: i + 1,
      totalRounds: totalMinutes,
    ));
  }
}

class TabataConfig extends WorkoutConfig {
  final int workSeconds, restSeconds, roundsPerSet, totalSets, restBetweenSetsSeconds;
  TabataConfig({
    required this.workSeconds,
    required this.restSeconds,
    required this.roundsPerSet,
    required this.totalSets,
    required this.restBetweenSetsSeconds
  }) : super(phaseType: TimerType.tabata);

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases) {
    List<WorkoutInterval> intervals = [];
    for (int set = 1; set <= totalSets; set++) {
      for (int round = 1; round <= roundsPerSet; round++) {
        intervals.add(WorkoutInterval(
          id: "tabata_work_${set}_$round",
          title: "LAVORO",
          durationSeconds: workSeconds,
          type: IntervalType.work,
          sourcePhase: phaseType,
          currentPhase: currentPhase,
          totalPhases: totalPhases,
          currentRound: round,
          totalRounds: roundsPerSet,
        ));
        intervals.add(WorkoutInterval(
          id: "tabata_rest_${set}_$round",
          title: "RIPOSO",
          durationSeconds: restSeconds,
          type: IntervalType.rest,
          sourcePhase: phaseType,
          currentPhase: currentPhase,
          totalPhases: totalPhases,
          currentRound: round,
          totalRounds: roundsPerSet,
        ));
      }
    }
    return intervals;
  }
}

class AMRAPConfig extends WorkoutConfig {
  final int totalMinutes;
  AMRAPConfig({required this.totalMinutes}) : super(phaseType: TimerType.amrap);

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases) {
    return [WorkoutInterval(
      id: "amrap_${DateTime.now().microsecondsSinceEpoch}",
      title: "AMRAP",
      durationSeconds: totalMinutes * 60,
      type: IntervalType.work,
      sourcePhase: phaseType,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      currentRound: 1,
      totalRounds: 1,
    )];
  }
}

class ForTimeConfig extends WorkoutConfig {
  final int totalMinutes;
  ForTimeConfig({required this.totalMinutes}) : super(phaseType: TimerType.fortime);

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases) {
    return [WorkoutInterval(
      id: "fortime_${DateTime.now().microsecondsSinceEpoch}",
      title: "FOR TIME",
      durationSeconds: totalMinutes * 60,
      type: IntervalType.work,
      sourcePhase: phaseType,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      currentRound: 1,
      totalRounds: 1,
    )];
  }
}

class CountdownConfig extends WorkoutConfig {
  final int minutes, seconds;
  CountdownConfig({required this.minutes, required this.seconds}) : super(phaseType: TimerType.countdown);

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases) {
    return [WorkoutInterval(
      id: "countdown_${DateTime.now().microsecondsSinceEpoch}",
      title: "COUNTDOWN",
      durationSeconds: (minutes * 60) + seconds,
      type: IntervalType.work,
      sourcePhase: phaseType,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      currentRound: 1,
      totalRounds: 1,
    )];
  }
}

class StopwatchConfig extends WorkoutConfig {
  StopwatchConfig() : super(phaseType: TimerType.stopwatch);

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases) {
    return [WorkoutInterval(
      id: "stopwatch_${DateTime.now().microsecondsSinceEpoch}",
      title: "STOPWATCH",
      durationSeconds: 0,
      type: IntervalType.work,
      sourcePhase: phaseType,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      currentRound: 1,
      totalRounds: 1,
    )];
  }
}

class RestConfig extends WorkoutConfig {
  final int durationSeconds;
  RestConfig({required this.durationSeconds}) : super(phaseType: TimerType.rest);

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases) {
    return [WorkoutInterval(
      id: "rest_${DateTime.now().microsecondsSinceEpoch}",
      title: "RIPOSO",
      durationSeconds: durationSeconds,
      type: IntervalType.rest,
      sourcePhase: phaseType,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      currentRound: 1,
      totalRounds: 1,
    )];
  }
}