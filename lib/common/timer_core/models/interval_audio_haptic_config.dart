import 'timercore_enums.dart';

/// Audio Triggers
class IntervalAudioConfig {
  final AudioHapticTrigger audioTrigger;
  final String fileName;

  const IntervalAudioConfig({
    this.audioTrigger = AudioHapticTrigger.start,
    this.fileName = '',
  });

  Map<String, dynamic> toJson() => {
    'audioTrigger': audioTrigger.name,
    'fileName': fileName,
  };

  IntervalAudioConfig fromJson(Map<String, dynamic> json) => IntervalAudioConfig(
    audioTrigger: AudioHapticTrigger.values.firstWhere((e) => e.name == json['audioTrigger']),
    fileName: json['fileName'] ?? '',
  );
}

/// Haptic Triggers
class IntervalHapticConfig {
  final AudioHapticTrigger trigger;
  final HapticPattern pattern;


  const IntervalHapticConfig({
    this.trigger = AudioHapticTrigger.start,
    this.pattern = HapticPattern.none,
  });

  Map<String, dynamic> toJson() => {
    'trigger': trigger.name,
    'pattern': pattern.name,
  };

  IntervalHapticConfig fromJson(Map<String, dynamic> json) => IntervalHapticConfig(
    trigger: AudioHapticTrigger.values.firstWhere((e) => e.name == json['trigger']),
    pattern: HapticPattern.values.firstWhere((e) => e.name == json['pattern']),
  );
}