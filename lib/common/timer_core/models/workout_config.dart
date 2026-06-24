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
  final List<List<IntervalAudioConfig>> audioConfigs;
  final List<List<IntervalHapticConfig>> hapticConfigs;
  const WorkoutConfig({
    required this.phaseType,
    required this.phaseTitle,
    required this.phaseSetting,
    required this.workoutTitle,
    required this.workoutId,
    required this.audioConfigs,
    required this.hapticConfigs
  });

  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases, String nextPhaseTitle, String nextPhaseSettings);
}

/// --- Implementation of real classes
/// +++ EMOM
class EMOMConfig extends WorkoutConfig {
  final int roundDuration;
  final int totalMinutes;
  EMOMConfig({required this.roundDuration, required this.totalMinutes, required String phaseTitle, required String phaseSetting, required String workoutTitle, required String workoutId, required List<List<IntervalAudioConfig>> audioConfigs, required List<List<IntervalHapticConfig>> hapticConfigs})
      : super(phaseType: TimerType.emom, phaseTitle: phaseTitle, phaseSetting: phaseSetting, workoutTitle: workoutTitle, workoutId: workoutId, audioConfigs: audioConfigs, hapticConfigs: hapticConfigs);

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases, String nextPhaseTitle, String nextPhaseSettings) {
    return List.generate(totalMinutes, (i) => WorkoutInterval(
      id: "emom_${DateTime.now().microsecondsSinceEpoch}_$i",
      title: ElandStrings.of('timer_emom').toUpperCase(),
      durationSeconds: roundDuration,
      type: IntervalType.work,
      sourcePhase: phaseType,
      currentRound: i + 1,
      totalRound: totalMinutes,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      nextPhaseTitle: nextPhaseTitle,
      nextPhaseSettings: nextPhaseSettings,
      workoutId: workoutId,
      workoutTitle: workoutTitle,
      audioConfig: audioConfigs[i],
      hapticConfig: hapticConfigs[i],
    ));
  }
}


/// +++ TABATA
class TabataConfig extends WorkoutConfig {
  final int workSeconds, restSeconds, roundsPerSet, totalSets, restBetweenSetsSeconds;

  TabataConfig({
    required this.workSeconds,
    required this.restSeconds,
    required this.roundsPerSet,
    required this.totalSets,
    required this.restBetweenSetsSeconds,
    required String phaseTitle,
    required String phaseSetting,
    required String workoutTitle,
    required String workoutId,
    // Nota: passiamo liste di liste perché ogni intervallo (work/rest) ha la sua config
    required List<List<IntervalAudioConfig>> audioConfigs,
    required List<List<IntervalHapticConfig>> hapticConfigs,
  }) : super(
    phaseType: TimerType.tabata,
    phaseTitle: phaseTitle,
    phaseSetting: phaseSetting,
    workoutTitle: workoutTitle,
    workoutId: workoutId,
    audioConfigs: audioConfigs,
    hapticConfigs: hapticConfigs,
  );

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases, String nextPhaseTitle, String nextPhaseSettings) {
    List<WorkoutInterval> intervals = [];
    int intervalIndex = 0; // Per mappare correttamente le config audio/haptic

    for (int set = 1; set <= totalSets; set++) {
      for (int round = 1; round <= roundsPerSet; round++) {

        // 1. Intervallo di LAVORO
        intervals.add(WorkoutInterval(
          id: "tabata_work_${set}_$round",
          title: "LAVORO",
          durationSeconds: workSeconds,
          type: IntervalType.work,
          sourcePhase: phaseType,
          currentPhase: currentPhase,
          totalPhases: totalPhases,
          currentRound: round,
          totalRound: roundsPerSet,
          nextPhaseTitle: nextPhaseTitle,
          nextPhaseSettings: nextPhaseSettings,
          workoutTitle: workoutTitle,
          workoutId: workoutId,
          audioConfig: audioConfigs[intervalIndex], // Config corretta per questo step
          hapticConfig: hapticConfigs[intervalIndex],
        ));
        intervalIndex++;

        // 2. Intervallo di RIPOSO
        intervals.add(WorkoutInterval(
          id: "tabata_rest_${set}_$round",
          title: "RIPOSO",
          durationSeconds: restSeconds,
          type: IntervalType.rest,
          sourcePhase: phaseType,
          currentPhase: currentPhase,
          totalPhases: totalPhases,
          currentRound: round,
          totalRound: roundsPerSet,
          nextPhaseTitle: nextPhaseTitle,
          nextPhaseSettings: nextPhaseSettings,
          workoutTitle: workoutTitle,
          workoutId: workoutId,
          audioConfig: audioConfigs[intervalIndex],
          hapticConfig: hapticConfigs[intervalIndex],
        ));
        intervalIndex++;
      }

      // 3. (Opzionale) Gestione pausa tra set
      // Se vuoi aggiungere un intervallo di pausa extra tra i set, andrebbe aggiunto qui
    }
    return intervals;
  }
}

/*
// TODO: from here

class AMRAPConfig extends WorkoutConfig {
  final int totalMinutes;
  AMRAPConfig({
    required this.totalMinutes,
    required String phaseTitle,
    required String phaseSetting,
    required String workoutTitle,
    required String workoutId,
    required List<IntervalAudioConfig> audioConfigs,
    required List<IntervalHapticConfig> hapticConfigs,
  }) : super(phaseType: TimerType.amrap, phaseTitle: phaseTitle, phaseSetting: phaseSetting, workoutTitle: workoutTitle, workoutId: workoutId, audioConfigs: [audioConfigs], hapticConfigs: [hapticConfigs]);

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases, String nextPhaseTitle, String nextPhaseSettings) {
    return [WorkoutInterval(
      id: "amrap_${DateTime.now().microsecondsSinceEpoch}",
      title: "AMRAP",
      durationSeconds: totalMinutes * 60,
      type: IntervalType.work,
      sourcePhase: phaseType,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      currentRound: 1,
      totalRound: 1,
      nextPhaseTitle: nextPhaseTitle,
      nextPhaseSettings: nextPhaseSettings,
      workoutTitle: workoutTitle,
      workoutId: workoutId,
      audioConfig: audioConfigs,
      hapticConfig: hapticConfigs,
    )];
  }
}

class ForTimeConfig extends WorkoutConfig {
  final int totalMinutes;
  ForTimeConfig({required this.totalMinutes, required String phaseTitle, required String phaseSetting, required String workoutTitle, required String workoutId, required List<IntervalAudioConfig> audioConfigs, required List<IntervalHapticConfig> hapticConfigs})
      : super(phaseType: TimerType.fortime, phaseTitle: phaseTitle, phaseSetting: phaseSetting, workoutTitle: workoutTitle, workoutId: workoutId, audioConfigs: [audioConfigs], hapticConfigs: [hapticConfigs]);

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases, String nextPhaseTitle, String nextPhaseSettings) {
    return [WorkoutInterval(
      id: "fortime_${DateTime.now().microsecondsSinceEpoch}",
      title: "FOR TIME",
      durationSeconds: totalMinutes * 60,
      type: IntervalType.work,
      sourcePhase: phaseType,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      currentRound: 1,
      totalRound: 1,
      nextPhaseTitle: nextPhaseTitle,
      nextPhaseSettings: nextPhaseSettings,
      workoutTitle: workoutTitle,
      workoutId: workoutId,
      audioConfig: audioConfigs,
      hapticConfig: hapticConfigs,
    )];
  }
}

class CountdownConfig extends WorkoutConfig {
  final int minutes, seconds;
  CountdownConfig({required this.minutes, required this.seconds, required String phaseTitle, required String phaseSetting, required String workoutTitle, required String workoutId, required List<IntervalAudioConfig> audioConfigs, required List<IntervalHapticConfig> hapticConfigs})
      : super(phaseType: TimerType.countdown, phaseTitle: phaseTitle, phaseSetting: phaseSetting, workoutTitle: workoutTitle, workoutId: workoutId, audioConfigs: [audioConfigs], hapticConfigs: [hapticConfigs]);

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases, String nextPhaseTitle, String nextPhaseSettings) {
    return [WorkoutInterval(
      id: "countdown_${DateTime.now().microsecondsSinceEpoch}",
      title: "COUNTDOWN",
      durationSeconds: (minutes * 60) + seconds,
      type: IntervalType.work,
      sourcePhase: phaseType,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      currentRound: 1,
      totalRound: 1,
      nextPhaseTitle: nextPhaseTitle,
      nextPhaseSettings: nextPhaseSettings,
      workoutTitle: workoutTitle,
      workoutId: workoutId,
      audioConfig: audioConfigs,
      hapticConfig: hapticConfigs,
    )];
  }
}

class RestConfig extends WorkoutConfig {
  final int durationSeconds;
  RestConfig({required this.durationSeconds, required String phaseTitle, required String phaseSetting, required String workoutTitle, required String workoutId, required List<IntervalAudioConfig> audioConfigs, required List<IntervalHapticConfig> hapticConfigs})
      : super(phaseType: TimerType.rest, phaseTitle: phaseTitle, phaseSetting: phaseSetting, workoutTitle: workoutTitle, workoutId: workoutId, audioConfigs: [audioConfigs], hapticConfigs: [hapticConfigs]);

  @override
  List<WorkoutInterval> toIntervals(int currentPhase, int totalPhases, String nextPhaseTitle, String nextPhaseSettings) {
    return [WorkoutInterval(
      id: "rest_${DateTime.now().microsecondsSinceEpoch}",
      title: "RIPOSO",
      durationSeconds: durationSeconds,
      type: IntervalType.rest,
      sourcePhase: phaseType,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      currentRound: 1,
      totalRound: 1,
      nextPhaseTitle: nextPhaseTitle,
      nextPhaseSettings: nextPhaseSettings,
      workoutTitle: workoutTitle,
      workoutId: workoutId,
      audioConfig: audioConfigs,
      hapticConfig: hapticConfigs,
    )];
  }
}*/