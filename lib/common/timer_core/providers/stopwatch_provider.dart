import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stopwatch_state.dart';
import '../models/stopwatch_lap.dart';
import '../models/timercore_enums.dart';

class StopwatchNotifier extends Notifier<StopwatchState> {
  StreamSubscription? _serviceSubscription;
  final FlutterBackgroundService _backgroundService = FlutterBackgroundService();

  // The service only reports state changes (start, pause, lap...). While
  // running, the elapsed time is rendered from its anchor with a local clock.
  Timer? _clock;
  int? _anchorMs;

  @override
  StopwatchState build() {
    ref.onDispose(() {
      _serviceSubscription?.cancel();
      _clock?.cancel();
    });
    _listenToBackgroundService();
    _backgroundService.invoke('requestStatus');
    return StopwatchState.initial().copyWith(isLoading: true);
  }

  void _listenToBackgroundService(){
    _serviceSubscription = _backgroundService.on('uiUpdate').listen((event) {
      if (event == null) return;

      final status = event.containsKey('status')
          ? TimerStatus.values.firstWhere((e) => e.name == event['status'], orElse: () => TimerStatus.paused)
          : state.status;

      List<StopWatchLap>? newLaps;
      if (event.containsKey('lapTimes')) {
        final list = event['lapTimes'] as List<dynamic>?;
        if (list != null) {
          newLaps = list.map((e) => StopWatchLap(lapTimeMs: e as int)).toList();
        } else {
          newLaps = [];
        }
      }

      state = state.copyWith(
        status: status,
        elapsedMilliseconds: event['elapsedMilliseconds'] as int? ?? state.elapsedMilliseconds,
        elapsedSeconds: event['elapsedSeconds'] as int? ?? state.elapsedSeconds,
        elapsedMinutes: event['elapsedMinutes'] as int? ?? state.elapsedMinutes,
        elapsedHours: event['elapsedHours'] as int? ?? state.elapsedHours,
        isLoading: false,
        laps: newLaps ?? state.laps,
      );

      if (event.containsKey('anchorMs')) {
        _anchorMs = event['anchorMs'] as int?;
        _clock?.cancel();
        _clock = null;
        if (_anchorMs != null) {
          _clock = Timer.periodic(const Duration(milliseconds: 33), (_) => _tick());
        } else if (event['elapsedTotalMs'] is int) {
          _apply(event['elapsedTotalMs'] as int);
        }
      }
    });
  }

  void _tick() {
    final anchor = _anchorMs;
    if (anchor == null) return;
    _apply(DateTime.now().millisecondsSinceEpoch - anchor);
  }

  void _apply(int totalMs) {
    final ms = totalMs < 0 ? 0 : totalMs;
    state = state.copyWith(
      elapsedMilliseconds: ms % 1000,
      elapsedSeconds: (ms ~/ 1000) % 60,
      elapsedMinutes: (ms ~/ 60000) % 60,
      elapsedHours: ms ~/ 3600000,
    );
  }
}

final stopwatchProvider = NotifierProvider.autoDispose<StopwatchNotifier, StopwatchState>(() {
  return StopwatchNotifier();
});