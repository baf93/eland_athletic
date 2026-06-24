enum IntervalType {
  preparation,
  work,
  rest,
  cooldown,
}

enum HapticPattern {
  none,
  light,
  medium,
  heavy,
  doubleTap,
}

enum AudioHapticTrigger {
  start,
  half,
  tenSeconds,
  lastThreeSeconds,
  end,
}

enum TimerType {
  preparation,
  emom,
  tabata,
  amrap,
  fortime,
  countdown,
  rest
}

enum TimerStatus {
  idle,
  running,
  paused,
  completed
}