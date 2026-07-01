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

  void requestStatus() {
    // Per ora resta no-op su runtime.
    // Lo aggiungiamo dopo se serve anche per iOS.
  }

  void skipPhase() {
    _runtime.skipPhase();
  }
}