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
    ref.onDispose(() => _serviceSubscription?.cancel());
    _listenToBackgroundService();
    // Richiediamo lo stato iniziale appena il provider viene creato
    _backgroundService.invoke('requestStatus');
    return TimerState.initial();
  }

  void _listenToBackgroundService() {
    _serviceSubscription = _backgroundService.on('update').listen((event) {
      if (event == null) return;

      final statusString = event['status'] as String? ?? 'idle';
      final status = TimerStatus.values.firstWhere(
            (e) => e.name == statusString,
        orElse: () => TimerStatus.idle,
      );

      state = state.copyWith(
        remainingSeconds: event['remainingSeconds'] as int? ?? state.remainingSeconds,
        intervalProgress: event['intervalProgress'] as double? ?? state.intervalProgress,
        currentIntervalTitle: event['title'] as String? ?? state.currentIntervalTitle,
        status: status,
      );
    });
  }
}

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(() {
  return TimerNotifier();
});