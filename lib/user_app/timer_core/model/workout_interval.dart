import 'timer_enums.dart';
import 'interval_audio_haptic_config.dart';

class WorkoutInterval {
  // Interval Settings
  final String id;
  final String title;
  final String? notes;
  final int durationSeconds;
  final IntervalType type;
  final TimerType sourcePhase;
  final IntervalAudioConfig audioConfig;
  final IntervalHapticConfig hapticConfig;

  // UI Specific fields
  final int currentPhase;
  final int totalPhases;
  final int currentRound;
  final int totalRounds;
  final String? nextPhaseTitle;
  final String? nextPhaseSettings;

  const WorkoutInterval({
    required this.id,
    required this.title,
    this.notes,
    required this.durationSeconds,
    required this.type,
    required this.sourcePhase,
    this.audioConfig = const IntervalAudioConfig(),
    this.hapticConfig = const IntervalHapticConfig(),
    required this.currentPhase,
    required this.totalPhases,
    required this.currentRound,
    required this.totalRounds,
    this.nextPhaseTitle,
    this.nextPhaseSettings,
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
      totalRounds: totalRounds,
      nextPhaseTitle: nextPhaseTitle ?? this.nextPhaseTitle,
      nextPhaseSettings: nextPhaseSettings ?? this.nextPhaseSettings,
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
    'totalRounds': totalRounds,
    'nextPhaseTitle': nextPhaseTitle,
    'nextPhaseSettings': nextPhaseSettings,
    'audioConfig': audioConfig.toJson(),
    'hapticConfig': hapticConfig.toJson(),
  };
}