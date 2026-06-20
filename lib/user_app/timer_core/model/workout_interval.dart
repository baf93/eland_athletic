import 'timer_enums.dart';
import 'interval_audio_haptic_config.dart';
import 'workout_config.dart';

class WorkoutInterval {
  final String id;
  final String title;
  final String? notes;
  final int durationSeconds;
  final IntervalType type;
  final TimerType sourcePhase;
  final CountingDirection direction;
  final IntervalAudioConfig audioConfig;
  final IntervalHapticConfig hapticConfig;
  final Map<String, String>? audioOverrides;

  // Campi di contesto per la UI
  final int currentPhase;
  final int totalPhases;
  final int currentRound;
  final int totalRounds;
  final String? nextIntervalTitle;

  const WorkoutInterval({
    required this.id,
    required this.title,
    this.notes,
    required this.durationSeconds,
    required this.type,
    required this.sourcePhase,
    this.direction = CountingDirection.down,
    this.audioConfig = const IntervalAudioConfig(),
    this.hapticConfig = const IntervalHapticConfig(),
    this.audioOverrides,
    required this.currentPhase,
    required this.totalPhases,
    required this.currentRound,
    required this.totalRounds,
    this.nextIntervalTitle,
  });

  WorkoutInterval copyWith({String? nextIntervalTitle}) {
    return WorkoutInterval(
      id: id,
      title: title,
      notes: notes,
      durationSeconds: durationSeconds,
      type: type,
      sourcePhase: sourcePhase,
      direction: direction,
      audioConfig: audioConfig,
      hapticConfig: hapticConfig,
      audioOverrides: audioOverrides,
      currentPhase: currentPhase,
      totalPhases: totalPhases,
      currentRound: currentRound,
      totalRounds: totalRounds,
      nextIntervalTitle: nextIntervalTitle ?? this.nextIntervalTitle,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'sourcePhase': sourcePhase.name,
    // ... resto del JSON invariato
  };
}