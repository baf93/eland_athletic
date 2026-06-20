import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../timer_core/model/timer_enums.dart';
import '../timer_core/model/timer_state.dart';

class TimerNotifier extends Notifier<TimerState> {
  StreamSubscription? _serviceSubscription;
  final FlutterBackgroundService _backgroundService = FlutterBackgroundService();

  @override
  TimerState build() {

    ref.onDispose(() {
      _serviceSubscription?.cancel();
    });

    _listenToBackgroundService();

    return TimerState.initial();
  }

  void _listenToBackgroundService() {
    _serviceSubscription = _backgroundService.on('update').listen((event) {
      if (event == null) return;

      TimerStatus status;
      switch (event['status'] as String? ?? 'idle') {
        case 'running': status = TimerStatus.running; break;
        case 'paused': status = TimerStatus.paused; break;
        case 'completed': status = TimerStatus.completed; break;
        default: status = TimerStatus.idle;
      }

      state = state.copyWith(
        remainingSeconds: event['remainingSeconds'] as int? ?? 0,
        elapsedSeconds: event['elapsedSeconds'] as int? ?? 0,
        status: status,
        currentIntervalTitle: event['title'] as String? ?? '',
        currentIntervalNotes: event['notes'] as String?,
      );
    });
  }

  Future<void> startWorkout({
    required int durationSeconds,
    required CountingDirection direction,
    required String title,
    String? notes,
  }) async {
    final isRunning = await _backgroundService.isRunning();
    if (!isRunning) {
      await _backgroundService.startService();
    }

    _backgroundService.invoke('start', {
      'remainingSeconds': durationSeconds,
      'elapsedSeconds': 0,
      'direction': direction == CountingDirection.down ? 'down' : 'up',
      'title': title,
      'notes': notes,
      'audioHapticConfig': {
        'start': {'audio': 'beep_long', 'haptic': 'double'},
        'half': {'audio': 'beep_short', 'haptic': 'single'},
        'tenSec': {'audio': 'beep_short', 'haptic': 'single'},
        'countdown': {'audio': 'beep_short', 'haptic': 'single'},
        'end': {'audio': 'beep_long', 'haptic': 'double'},
      }
    });
  }

  void pause() {
    _backgroundService.invoke('pause');
  }

  void resume() {
    _backgroundService.invoke('resume');
  }

  void stop() {
    _backgroundService.invoke('stop');
    state = TimerState.initial();
  }
}

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(() {
  return TimerNotifier();
});