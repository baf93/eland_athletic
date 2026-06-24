import 'package:flutter_background_service/flutter_background_service.dart';
import '../models/workout_interval.dart';
import '../models/workout_phase_summary.dart';
import 'dart:async';

class WorkoutController {

  WorkoutController._privateConstructor();
  static final WorkoutController instance = WorkoutController._privateConstructor();

  final FlutterBackgroundService _service = FlutterBackgroundService();

  Future<void> launchWorkout(List<WorkoutInterval> queue, List<WorkoutPhaseSummary> uiPhaseSummary) async {

    if (!await _service.isRunning()) {
      await _service.startService();
      // Wait for the service to be running before sending data
      final Completer<void> readyCompleter = Completer<void>();

      final subscription = _service.on('serviceReady').listen((event) {
        if (!readyCompleter.isCompleted) {
          readyCompleter.complete();
        }
      });

      await readyCompleter.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => print(" [!] Service Start: Timeout waiting for service to be ready."),
      );
      await subscription.cancel();
    }

    final List<Map<String, dynamic>> jsonQueue = queue.map((interval) => interval.toJson()).toList();
    final List<Map<String, dynamic>> jsonUiPhaseList = uiPhaseSummary.map((phase) => phase.toJson()).toList();

    _service.invoke('startFullWorkout', {'queue': jsonQueue, 'uiPhaseList': jsonUiPhaseList});
  }

  void pauseWorkout() {
    _service.invoke('pause');
  }

  void resumeWorkout() {
    _service.invoke('resume');
  }

  void stopWorkout() {
    _service.invoke('stop');
  }

  void requestStatus() {
    _service.invoke('requestStatus');
  }
}