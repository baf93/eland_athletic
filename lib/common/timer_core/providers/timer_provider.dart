import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timercore_enums.dart';
import '../models/timer_state.dart';
import '../models/workout_phase_summary.dart';

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

      final status = event.containsKey('status')
          ? TimerStatus.values.firstWhere((e) => e.name == event['status'], orElse: () => TimerStatus.idle)
          : state.status;

      final timerType = event.containsKey('timerType')
          ? TimerType.values.firstWhere((e) => e.name == event['timerType'], orElse: () => TimerType.preparation)
          : state.timerType;

      final intervalType = event.containsKey('intervalType')
          ? IntervalType.values.firstWhere((e) => e.name == event['intervalType'], orElse: () => IntervalType.preparation)
          : state.intervalType;

      List<WorkoutPhaseSummary>? newSummary;
      if (event.containsKey('workoutPhaseSummary')) {
        final list = event['workoutPhaseSummary'] as List<dynamic>?;
        if (list != null) {
          newSummary = list.map((e) => WorkoutPhaseSummary.fromJson(e as Map<String, dynamic>)).toList();
        } else {
          newSummary = [];
        }
      }

      print('EVENT: ${event}');

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
        intervalProgress: (event['intervalProgress'] as num?)?.toDouble() ?? state.intervalProgress,
        timerType: timerType,
        intervalType: intervalType,
        workoutPhaseSummary: newSummary ?? state.workoutPhaseSummary,
        totalRound: event['totalRound'] as int? ?? state.totalRound,
        currentRound: event['currentRound'] as int? ?? state.currentRound,
      );
    });
  }
}

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(() {
  return TimerNotifier();
});