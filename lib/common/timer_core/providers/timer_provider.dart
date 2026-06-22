import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timercore_enums.dart';
import '../models/timer_state.dart';
import '../controllers/workout_controller.dart';

class TimerNotifier extends Notifier<TimerState> {
  StreamSubscription? _serviceSubscription;
  final FlutterBackgroundService _backgroundService = FlutterBackgroundService();

  @override
  TimerState build() {
    ref.onDispose(() => _serviceSubscription?.cancel());
    _listenToBackgroundService();
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

      final timerTypeString = event['timerType'] as String? ?? 'preparation';
      final timerType = TimerType.values.firstWhere(
            (e) => e.name == timerTypeString,
        orElse: () => TimerType.preparation,
      );

      final intervalTypeString = event['intervalType'] as String? ?? 'preparation';
      final intervalType = IntervalType.values.firstWhere(
            (e) => e.name == intervalTypeString,
        orElse: () => IntervalType.preparation,
      );

      // TODO:
      //         'workoutPhaseSummary': uiPhaseList,
      //   final List<WorkoutPhaseSummary> workoutPhaseSummary;

      state = state.copyWith(
        remainingSeconds: event['remainingSeconds'] as int? ?? state.remainingSeconds,
        status: status,
        currentIntervalTitle: event['currentIntervalTitle'] as String? ?? state.currentIntervalTitle,
        currentIntervalNotes: event['currentIntervalNotes'] as String? ?? state.currentIntervalNotes,
        currentPhaseIndex: event['currentPhaseIndex'] as int? ?? state.currentPhaseIndex,
        totalPhases: event['totalPhases'] as int? ?? state.totalPhases,
        workoutTitle: event['workoutTitle'] as String? ?? state.workoutTitle,
        workoutId: event['workoutId'] as String? ?? state.workoutId,
        isLastPhase: event['isLastPhase'] as bool? ?? state.isLastPhase,
        intervalProgress: event['intervalProgress'] as double? ?? state.intervalProgress,
        timerType: timerType,
        intervalType: intervalType,

      );
    });
  }
}

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(() {
  return TimerNotifier();
});