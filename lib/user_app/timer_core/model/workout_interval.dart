import 'timer_enums.dart';
import 'interval_audio_haptic_config.dart';

class WorkoutInterval {
  final String id;
  final String title;
  final String? notes;
  final int durationSeconds;
  final IntervalType type;
  final CountingDirection direction;
  final IntervalAudioConfig audioConfig;
  final IntervalHapticConfig hapticConfig;

  const WorkoutInterval({
    required this.id,
    required this.title,
    this.notes,
    required this.durationSeconds,
    required this.type,
    this.direction = CountingDirection.down,
    this.audioConfig = const IntervalAudioConfig(),
    this.hapticConfig = const IntervalHapticConfig(),
  });
}