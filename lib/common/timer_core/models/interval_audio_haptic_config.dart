import 'timercore_enums.dart';

/// TODO: Capire se serve veramente la classe o le configurazioni dell'audio e del feedback aptico le mettiamo nella workout_config.dart

/// Audio Triggers
class IntervalAudioConfig {
  final AudioTriggerType onStart;
  final AudioTriggerType onHalfway;
  final AudioTriggerType onTenSecondsLeft;
  final AudioTriggerType onCountdownSeconds;
  final AudioTriggerType onEnd;

  const IntervalAudioConfig({
    this.onStart = AudioTriggerType.go,
    this.onHalfway = AudioTriggerType.half,
    this.onTenSecondsLeft = AudioTriggerType.tenSeconds,
    this.onCountdownSeconds = AudioTriggerType.countdown321,
    this.onEnd = AudioTriggerType.nextStage,
  });

  Map<String, dynamic> toJson() => {
    'onStart': onStart.name,
    'onHalfway': onHalfway.name,
    'onTenSecondsLeft': onTenSecondsLeft.name,
    'onCountdownSeconds': onCountdownSeconds.name,
    'onEnd': onEnd.name,
  };
}

/// Haptic Triggers
class IntervalHapticConfig {
  final HapticPattern onStart;
  final HapticPattern onHalfway;
  final HapticPattern onTenSecondsLeft;
  final HapticPattern onCountdownSeconds;
  final HapticPattern onEnd;

  const IntervalHapticConfig({
    this.onStart = HapticPattern.heavy,
    this.onHalfway = HapticPattern.none,
    this.onTenSecondsLeft = HapticPattern.none,
    this.onCountdownSeconds = HapticPattern.light,
    this.onEnd = HapticPattern.doubleTap,
  });

  Map<String, dynamic> toJson() => {
    'onStart': onStart.name,
    'onHalfway': onHalfway.name,
    'onTenSecondsLeft': onTenSecondsLeft.name,
    'onCountdownSeconds': onCountdownSeconds.name,
    'onEnd': onEnd.name,
  };
}