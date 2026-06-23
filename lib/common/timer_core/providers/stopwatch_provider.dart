import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stopwatch_state.dart';
import '../models/stopwatch_lap.dart';
import '../models/timercore_enums.dart';

class StopwatchNotifier extends Notifier<StopwatchState> {
  StreamSubscription? _serviceSubscription;
  final FlutterBackgroundService _backgroundService = FlutterBackgroundService();

  @override
  StopwatchState build() {
    ref.onDispose(() => _serviceSubscription?.cancel());
    _listenToBackgroundService();
    return StopwatchState.initial();
  }

  void _listenToBackgroundService(){
    _serviceSubscription = _backgroundService.on('uiUpdate').listen((event) {
      if (event == null) return;

      print('EVENT: $event');

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
        laps: newLaps ?? state.laps,
      );
    });
  }
}

final stopwatchProvider = NotifierProvider<StopwatchNotifier, StopwatchState>(() {
  return StopwatchNotifier();
});