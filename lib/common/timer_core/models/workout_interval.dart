import 'timercore_enums.dart';
import 'interval_audio_haptic_config.dart';

class WorkoutInterval {
  // Interval Settings
  final String id;
  final String title;
  final String? notes;
  final int durationSeconds;
  final IntervalType type;
  final TimerType sourcePhase;
  final List<IntervalAudioConfig> audioConfig;
  final List<IntervalHapticConfig> hapticConfig;

  // UI Specific fields
  final int currentPhase;
  final int totalPhases;
  final int currentRound;
  final int totalRound;
  final String? nextPhaseTitle;
  final String? nextPhaseSettings;
  final String? workoutTitle;
  final String? workoutId;

  const WorkoutInterval({
    required this.id,
    required this.title,
    this.notes,
    required this.durationSeconds,
    required this.type,
    required this.sourcePhase,
    this.audioConfig = const [],
    this.hapticConfig = const [],
    required this.currentPhase,
    required this.totalPhases,
    required this.currentRound,
    required this.totalRound,
    this.nextPhaseTitle,
    this.nextPhaseSettings,
    this.workoutTitle,
    this.workoutId
  });

  WorkoutInterval copyWith({String? nextPhaseTitle, String? nextPhaseSettings}) {
    return WorkoutInterval(
      id: id,
      title: title,
      notes: notes,
      durationSeconds: durationSeconds,
      type: type,
      sourcePhase: sourcePhase,
      audioConfig: audioConfig,
      hapticConfig: hapticConfig,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      currentRound: currentRound,
      totalRound: totalRound,
      nextPhaseTitle: nextPhaseTitle ?? this.nextPhaseTitle,
      nextPhaseSettings: nextPhaseSettings ?? this.nextPhaseSettings,
      workoutTitle:  workoutTitle,
      workoutId: workoutId
    );
  }

  /// Method needed for InterProcess Communication
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'notes': notes,
    'duration': durationSeconds,
    'type': type.name,
    'sourcePhase': sourcePhase.name,
    'currentPhase': currentPhase,
    'totalPhases': totalPhases,
    'currentRound': currentRound,
    'totalRound': totalRound,
    'nextPhaseTitle': nextPhaseTitle,
    'nextPhaseSettings': nextPhaseSettings,
    'workoutTitle': workoutTitle,
    'workoutId': workoutId,
    'audioConfigs': audioConfig.map((item) => item.toJson()).toList(),
    'hapticConfigs': hapticConfig.map((item) => item.toJson()).toList(),
  };
}