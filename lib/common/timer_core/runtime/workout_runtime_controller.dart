import 'eland_workout_runtime.dart';
import '../models/workout_interval.dart';
import '../models/workout_phase_summary.dart';

class WorkoutRuntimeController {
  WorkoutRuntimeController._();

  static final WorkoutRuntimeController instance = WorkoutRuntimeController._();

  final ElandWorkoutRuntime _runtime = ElandWorkoutRuntime.create();

  ElandWorkoutRuntime get runtime => _runtime;

  Future<void> initialize() {
    return _runtime.initialize();
  }

  Future<void> launchWorkout(
      List<WorkoutInterval> queue,
      List<WorkoutPhaseSummary> uiPhaseSummary,
      ) {
    return _runtime.launchWorkout(queue, uiPhaseSummary);
  }

  Future<void> start({
    required String workoutId,
    required String workoutTitle,
  }) {
    return _runtime.start(
      workoutId: workoutId,
      workoutTitle: workoutTitle,
    );
  }

  Future<void> update(ElandWorkoutRuntimeState state) {
    return _runtime.update(state);
  }

  Future<void> pause() {
    return _runtime.pause();
  }

  Future<void> resume() {
    return _runtime.resume();
  }

  Future<void> skipPhase() {
    return _runtime.skipPhase();
  }

  Future<void> stop() {
    return _runtime.stop();
  }
}