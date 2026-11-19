import 'package:flutter_background_service/flutter_background_service.dart';

import '../models/workout_interval.dart';
import '../models/workout_phase_summary.dart';
import '../runtime/workout_runtime_controller.dart';

class WorkoutController {
  WorkoutController._privateConstructor();

  static final WorkoutController instance =
  WorkoutController._privateConstructor();

  final WorkoutRuntimeController _runtime =
      WorkoutRuntimeController.instance;

  Future<void> launchWorkout(
      List<WorkoutInterval> queue,
      List<WorkoutPhaseSummary> uiPhaseSummary,
      ) async {
    await _runtime.launchWorkout(queue, uiPhaseSummary);
  }

  void pauseWorkout() {
    _runtime.pause();
  }

  void resumeWorkout() {
    _runtime.resume();
  }

  void stopWorkout() {
    _runtime.stop();
  }

  /// Asks the service to resend the full state (used when a workout page is
  /// reopened, e.g. from the notification).
  void requestStatus() {
    FlutterBackgroundService().invoke('requestStatus');
  }

  void skipPhase() {
    _runtime.skipPhase();
  }
}