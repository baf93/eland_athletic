import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../timer_core/models/timercore_enums.dart';
import '../timer_core/models/timer_state.dart';
import '../timer_core/controllers/workout_controller.dart';

class TimerNotifier extends Notifier<TimerState> {
  StreamSubscription? _serviceSubscription;
  final FlutterBackgroundService _backgroundService = FlutterBackgroundService();

  @override
  TimerState build() {
    ref.onDispose(() => _serviceSubscription?.cancel());
    _listenToBackgroundService();

    WorkoutController.instance.requestStatus();
    return TimerState.initial();
  }

  void _listenToBackgroundService() {
    _serviceSubscription = _backgroundService.on('uiUpdate').listen((event) {
      if (event == null) return;

      final statusString = event['status'] as String? ?? 'idle';
      final status = TimerStatus.values.firstWhere(
            (e) => e.name == statusString,
        orElse: () => TimerStatus.idle,
      );

      //         'intervalType': interval['type'],
      //         'timerType': interval['sourcePhase'] as String,
      //         'workoutPhaseSummary': uiPhaseList,

      //        remainingSeconds: event['remainingSeconds'] as int? ?? state.remainingSeconds,
      //         intervalProgress: event['intervalProgress'] as double? ?? state.intervalProgress,
      //         currentIntervalTitle: event['currentIntervalTitle'] as String? ?? state.currentIntervalTitle,

      //   final IntervalType intervalType;
      //   final TimerType timerType;
      //   final List<WorkoutPhaseSummary> workoutPhaseSummary;

      state = state.copyWith(
        remainingSeconds: event['remainingSeconds'] as int? ?? state.remainingSeconds,
        status: status,
        currentIntervalTitle: event['currentIntervalTitle'] as String? ?? state.currentIntervalTitle,
        currentIntervalNotes: event['currentIntervalNotes'] as String? ?? state.currentIntervalTitle,
        currentPhaseIndex: event['currentPhaseIndex'] as int? ?? state.currentPhaseIndex,
        totalPhases: event['totalPhases'] as int? ?? state.totalPhases,
        workoutTitle: event['workoutTitle'] as String? ?? state.workoutTitle,
        workoutId: event['workoutId'] as String? ?? state.workoutId,
        isLastPhase: event['isLastPhase'] as bool? ?? state.isLastPhase,
        intervalProgress: event['intervalProgress'] as double? ?? state.intervalProgress,



      );
    });
  }
}

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(() {
  return TimerNotifier();
});