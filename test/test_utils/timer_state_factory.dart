import 'package:eland_athletic/common/timer_core/models/timer_state.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';

TimerState timerStateForTest({
  int remainingSeconds = 90,
  int elapsedSeconds = 30,
  TimerStatus status = TimerStatus.running,
  IntervalType intervalType = IntervalType.work,
  TimerType timerType = TimerType.countdown,
  double intervalProgress = 0.25,
  bool isOvertime = false,
}) {
  return TimerState.initial().copyWith(
    isLoading: false,
    remainingSeconds: remainingSeconds,
    elapsedSeconds: elapsedSeconds,
    status: status,
    intervalType: intervalType,
    timerType: timerType,
    intervalProgress: intervalProgress,
    currentIntervalTitle: timerType.name.toUpperCase(),
    workoutTitle: timerType.name.toUpperCase(),
    workoutId: '${timerType.name}_qt',
    currentRound: 2,
    totalRound: 8,
    currentSet: 1,
    totalSet: 3,
    isOvertime: isOvertime,
  );
}
