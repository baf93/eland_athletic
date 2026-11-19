import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timercore_enums.dart';
import '../models/timer_state.dart';
import '../models/workout_phase_summary.dart';

class TimerNotifier extends Notifier<TimerState> {
  StreamSubscription? _serviceSubscription;
  final FlutterBackgroundService _backgroundService = FlutterBackgroundService();

  // Local interval clock: the service sends the epoch ms at which the current
  // interval read 00:00 and the UI counts on its own, so the display does not
  // stutter with the timing of the per-second messages.
  Timer? _clock;
  int? _anchorMs;
  int _durationSeconds = 0;

  @override
  TimerState build() {
    ref.onDispose(() {
      _serviceSubscription?.cancel();
      _clock?.cancel();
    });
    _listenToBackgroundService();
    return TimerState.initial().copyWith(isLoading: true);
  }

  void _setClock(int? anchorMs) {
    _anchorMs = anchorMs;
    _clock?.cancel();
    _clock = null;
    if (anchorMs == null) return;
    _clock = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
    _tick();
  }

  void _tick() {
    final anchor = _anchorMs;
    if (anchor == null || state.status != TimerStatus.running) return;
    final elapsed =
        ((DateTime.now().millisecondsSinceEpoch - anchor) ~/ 1000).clamp(0, 1 << 30);
    if (elapsed == state.elapsedSeconds && !state.isLoading) return;
    final duration = _durationSeconds;
    state = state.copyWith(
      elapsedSeconds: elapsed,
      // The service moves to the next interval at 0: never show negatives.
      remainingSeconds: state.timerType == TimerType.fortime
          ? duration - elapsed
          : (duration - elapsed).clamp(0, duration),
      intervalProgress:
          duration > 0 ? (elapsed / duration).clamp(0.0, 1.0) : 1.0,
      isOvertime: state.timerType == TimerType.fortime && elapsed > duration,
    );
  }

  void _listenToBackgroundService() {

    _serviceSubscription = _backgroundService.on('uiUpdate').listen((event) {
      if (event == null) return;

      // Per-second ticks carry no anchor: while the local clock runs, their
      // time values are redundant and only arrive later than ours.
      final hasClock = event.containsKey('anchorMs');
      if (!hasClock &&
          _anchorMs != null &&
          event['status'] == 'running' &&
          event.length <= 6) {
        return;
      }
      if (event.containsKey('durationSeconds')) {
        _durationSeconds = event['durationSeconds'] as int? ?? 0;
      }

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

      final notesChanged = event.containsKey('currentIntervalNotes');
      final rawResults = event['phaseResults'] as List<dynamic>?;

      state = state.copyWith(
        remainingSeconds: event['remainingSeconds'] as int? ?? state.remainingSeconds,
        status: status,
        currentIntervalTitle: event['currentIntervalTitle'] as String? ?? state.currentIntervalTitle,
        // A new interval always reports its notes (possibly none): do not
        // keep showing the notes of the previous phase.
        currentIntervalNotes: event['currentIntervalNotes'] as String?,
        clearIntervalNotes: notesChanged && event['currentIntervalNotes'] == null,
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
        currentSet: event['currentSet'] as int? ?? state.currentSet,
        totalSet: event['totalSet'] as int? ?? state.totalSet,
        isOvertime: event['isOvertime'] as bool? ?? state.isOvertime,
        elapsedSeconds: event['elapsedSeconds'] as int? ?? state.elapsedSeconds,
        isLoading: false,
        activeSeconds: event['activeSeconds'] as int?,
        phaseResults: rawResults
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
      );

      if (hasClock) {
        _setClock(event['anchorMs'] as int?);
      } else if (status != TimerStatus.running) {
        _setClock(null);
      }
    });
  }
}

final timerProvider = NotifierProvider.autoDispose<TimerNotifier, TimerState>(() {
  return TimerNotifier();
});