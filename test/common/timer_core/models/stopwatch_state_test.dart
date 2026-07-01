import 'package:eland_athletic/common/timer_core/models/stopwatch_lap.dart';
import 'package:eland_athletic/common/timer_core/models/stopwatch_state.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StopwatchState', () {
    test('initial returns paused loading state', () {
      final state = StopwatchState.initial();

      expect(state.status, TimerStatus.paused);
      expect(state.elapsedMilliseconds, 0);
      expect(state.elapsedSeconds, 0);
      expect(state.elapsedMinutes, 0);
      expect(state.elapsedHours, 0);
      expect(state.laps, isEmpty);
      expect(state.isLoading, isTrue);
    });

    test('copyWith updates only provided fields', () {
      final state = StopwatchState.initial().copyWith(
        status: TimerStatus.running,
        elapsedMilliseconds: 120,
        elapsedSeconds: 1,
        laps: const [StopWatchLap(lapTimeMs: 1200)],
        isLoading: false,
      );

      expect(state.status, TimerStatus.running);
      expect(state.elapsedMilliseconds, 120);
      expect(state.elapsedSeconds, 1);
      expect(state.laps, hasLength(1));
      expect(state.isLoading, isFalse);
      expect(state.elapsedHours, 0);
    });
  });

  group('StopWatchLap', () {
    test('serializes and deserializes lap time', () {
      const lap = StopWatchLap(lapTimeMs: 1234);
      final restored = StopWatchLap.fromJson(lap.toJson());

      expect(restored.lapTimeMs, 1234);
      expect(lap.toString(), '{lapTimeMs: 1234}');
    });
  });
}
