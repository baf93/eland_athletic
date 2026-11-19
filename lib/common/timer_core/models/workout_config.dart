import 'package:eland_athletic/common/strings.dart';
import 'package:eland_athletic/common/timer_core/models/interval_audio_haptic_config.dart';

import 'workout_interval.dart';
import 'timercore_enums.dart';


/// --- Abstract Workout Config class
abstract class WorkoutConfig {
  final TimerType phaseType;
  final String phaseTitle;
  final String phaseSetting;
  final String workoutTitle;
  final String workoutId;
  /// Free text shown on the workout screen while this phase runs.
  final String? notes;
  final List<List<IntervalAudioConfig>> audioConfigs;
  final List<List<IntervalHapticConfig>> hapticConfigs;
  const WorkoutConfig({
    required this.phaseType,
    required this.phaseTitle,
    required this.phaseSetting,
    required this.workoutTitle,
    required this.workoutId,
    this.notes,
    required this.audioConfigs,
    required this.hapticConfigs
  });

  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases);
}

/// --- Implementation of real classes
/// +++ EMOM
class EMOMConfig extends WorkoutConfig {
  final int roundDuration;
  final int totalMinutes;
  EMOMConfig({
    required this.roundDuration,
    required this.totalMinutes,
    required super.phaseTitle,
    required super.phaseSetting,
    required super.workoutTitle,
    required super.workoutId,
    super.notes,
    required super.audioConfigs,
    required super.hapticConfigs,
  }) : super(phaseType: TimerType.emom);

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases) {
    return List.generate(totalMinutes, (i) => WorkoutInterval(
      notes: notes,
      id: "emom_${DateTime.now().microsecondsSinceEpoch}_$i",
      title: ElandStrings.of('timer_emom').toUpperCase(),
      durationSeconds: roundDuration,
      type: IntervalType.work,
      sourcePhase: phaseType,
      currentRound: i + 1,
      currentSet: 1,
      totalSet: 1,
      totalRound: totalMinutes,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      workoutId: workoutId,
      workoutTitle: workoutTitle,
      audioConfig: audioConfigs[i],
      hapticConfig: hapticConfigs[i],
    ));
  }
}


/// +++ TABATA
class TabataConfig extends WorkoutConfig {
  final int workSeconds, restSeconds, roundsPerSet, totalSets, restBetweenSets;

  TabataConfig({
    required this.workSeconds,
    required this.restSeconds,
    required this.roundsPerSet,
    required this.totalSets,
    required this.restBetweenSets,
    required super.phaseTitle,
    required super.phaseSetting,
    required super.workoutTitle,
    required super.workoutId,
    super.notes,
    required super.audioConfigs,
    required super.hapticConfigs,
  }) : super(phaseType: TimerType.tabata);

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases) {

    final totalIntervals = (roundsPerSet * totalSets * 2) - 1;

    final List<WorkoutInterval> intervals = List.generate(totalIntervals, (i){
      bool isWork = i.isEven;
      int currentRound = (i ~/ 2) % roundsPerSet +1;
      int currentSets = i ~/ (roundsPerSet * 2) + 1;

      if(isWork){
        return WorkoutInterval(
          notes: notes,
          id: "tabata_work_$i",
          title: ElandStrings.of('timer_tabata').toUpperCase(),
          durationSeconds: workSeconds,
          type: IntervalType.work,
          sourcePhase: phaseType,
          currentRound: currentRound,
          totalRound: roundsPerSet,
          currentSet: currentSets,
          totalSet: totalSets,
          currentPhase: currentPhase,
          totalPhases: totalPhases,
          workoutId: workoutId,
          workoutTitle: workoutTitle,
          audioConfig: audioConfigs[i],
          hapticConfig: hapticConfigs[i],
        );
      }else{
        return WorkoutInterval(
          notes: notes,
          id: "tabata_rest_$i",
          title: ElandStrings.of('timer_tabata').toUpperCase(),
          durationSeconds: currentRound == roundsPerSet ? restBetweenSets : restSeconds,
          type: currentRound == roundsPerSet ? IntervalType.cooldown : IntervalType.rest,
          sourcePhase: phaseType,
          currentRound: currentRound,
          totalRound: roundsPerSet,
          currentSet: currentSets,
          totalSet: totalSets,
          currentPhase: currentPhase,
          totalPhases: totalPhases,
          workoutId: workoutId,
          workoutTitle: workoutTitle,
          audioConfig: audioConfigs[i],
          hapticConfig: hapticConfigs[i],
        );
      }
    });

    return intervals;
  }
}

/// +++ AMRAP
class AMRAPConfig extends WorkoutConfig {
  final int totalMinutes;
  final int totalSeconds;
  AMRAPConfig({
    required this.totalMinutes,
    required this.totalSeconds,
    required super.phaseTitle,
    required super.phaseSetting,
    required super.workoutTitle,
    required super.workoutId,
    super.notes,
    required super.audioConfigs,
    required super.hapticConfigs
  }) : super(
    phaseType: TimerType.amrap
  );

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases) {
    return [WorkoutInterval(
      notes: notes,
      id: "amrap_${DateTime.now().microsecondsSinceEpoch}",
      title: ElandStrings.of('timer_amrap').toUpperCase(),
      durationSeconds: totalMinutes * 60 + totalSeconds,
      type: IntervalType.work,
      sourcePhase: phaseType,
      currentRound: 1,
      totalRound: 1,
      currentSet: 1,
      totalSet: 1,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      workoutId: workoutId,
      workoutTitle: workoutTitle,
      audioConfig: audioConfigs[0],
      hapticConfig: hapticConfigs[0],
    )];
  }
}

/// +++ FORTIME
class FortimeConfig extends WorkoutConfig {
  final int totalMinutes;
  final int totalSeconds;
  FortimeConfig({
    required this.totalMinutes,
    required this.totalSeconds,
    required super.phaseTitle,
    required super.phaseSetting,
    required super.workoutTitle,
    required super.workoutId,
    super.notes,
    required super.audioConfigs,
    required super.hapticConfigs
  }) : super(
      phaseType: TimerType.fortime
  );

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases) {
    return [WorkoutInterval(
      notes: notes,
      id: "fortime_${DateTime.now().microsecondsSinceEpoch}",
      title: ElandStrings.of('timer_fortime').toUpperCase(),
      durationSeconds: totalMinutes * 60 + totalSeconds,
      type: IntervalType.work,
      sourcePhase: phaseType,
      currentRound: 1,
      totalRound: 1,
      currentSet: 1,
      totalSet: 1,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      workoutId: workoutId,
      workoutTitle: workoutTitle,
      audioConfig: audioConfigs[0],
      hapticConfig: hapticConfigs[0],
    )];
  }
}

/// +++ COUNTDOWN
class CountdownConfig extends WorkoutConfig {
  final int totalMinutes;
  final int totalSeconds;
  CountdownConfig({
    required this.totalMinutes,
    required this.totalSeconds,
    required super.phaseTitle,
    required super.phaseSetting,
    required super.workoutTitle,
    required super.workoutId,
    super.notes,
    required super.audioConfigs,
    required super.hapticConfigs
  }) : super(
      phaseType: TimerType.countdown
  );

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases) {
    return [WorkoutInterval(
      notes: notes,
      id: "countdown_${DateTime.now().microsecondsSinceEpoch}",
      title: ElandStrings.of('timer_countdown').toUpperCase(),
      durationSeconds: totalMinutes * 60 + totalSeconds,
      type: IntervalType.work,
      sourcePhase: phaseType,
      currentRound: 1,
      totalRound: 1,
      currentSet: 1,
      totalSet: 1,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      workoutId: workoutId,
      workoutTitle: workoutTitle,
      audioConfig: audioConfigs[0],
      hapticConfig: hapticConfigs[0],
    )];
  }
}

/// +++ REST
class RestConfig extends WorkoutConfig {
  final int totalMinutes;
  final int totalSeconds;
  RestConfig({
    required this.totalMinutes,
    required this.totalSeconds,
    required super.phaseTitle,
    required super.phaseSetting,
    required super.workoutTitle,
    required super.workoutId,
    super.notes,
    required super.audioConfigs,
    required super.hapticConfigs
  }) : super(
      phaseType: TimerType.rest
  );

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases) {
    return [WorkoutInterval(
      notes: notes,
      id: "rest_${DateTime.now().microsecondsSinceEpoch}",
      title: ElandStrings.of('timer_rest').toUpperCase(),
      durationSeconds: totalMinutes * 60 + totalSeconds,
      type: IntervalType.rest,
      sourcePhase: phaseType,
      currentRound: 1,
      totalRound: 1,
      currentSet: 1,
      totalSet: 1,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      workoutId: workoutId,
      workoutTitle: workoutTitle,
      audioConfig: audioConfigs[0],
      hapticConfig: hapticConfigs[0],
    )];
  }
}