import 'timercore_enums.dart';
import 'stopwatch_lap.dart';

class StopwatchState {
  final TimerStatus status;
  final int elapsedMilliseconds;
  final int elapsedSeconds;
  final int elapsedMinutes;
  final int elapsedHours;
  final List<StopWatchLap> laps;
  final bool isLoading;

  const StopwatchState({
    required this.status,
    required this.elapsedMilliseconds,
    required this.elapsedSeconds,
    required this.elapsedMinutes,
    required this.elapsedHours,
    required this.laps,
    required this.isLoading,
  });

  factory StopwatchState.initial(){
    return const StopwatchState(
        status: TimerStatus.paused,
        elapsedMilliseconds: 0,
        elapsedSeconds: 0,
        elapsedMinutes: 0,
        elapsedHours: 0,
        isLoading: true,
        laps: []
    );
  }

  StopwatchState copyWith({
    TimerStatus? status,
    int? elapsedMilliseconds,
    int? elapsedSeconds,
    int? elapsedMinutes,
    int? elapsedHours,
    bool? isLoading,
    List<StopWatchLap>? laps,
  }) {
    return StopwatchState(
      status: status ?? this.status,
      elapsedMilliseconds: elapsedMilliseconds ?? this.elapsedMilliseconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      elapsedMinutes: elapsedMinutes ?? this.elapsedMinutes,
      elapsedHours: elapsedHours ?? this.elapsedHours,
      isLoading: isLoading ?? this.isLoading,
      laps: laps ?? this.laps,
    );
  }
}
