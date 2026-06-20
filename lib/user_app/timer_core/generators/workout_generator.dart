import '../model/workout_interval.dart';
import '../model/workout_config.dart';

class WorkoutGenerator {
  List<WorkoutInterval> generate(List<WorkoutConfig> sessionConfigs) {
    int totalPhases = sessionConfigs.length;

    final List<WorkoutInterval> finalQueue = sessionConfigs
        .asMap()
        .entries
        .expand((entry) => entry.value.toIntervals(entry.key + 1, totalPhases))
        .toList();

    return _linkNextIntervals(finalQueue);
  }

  List<WorkoutInterval> _linkNextIntervals(List<WorkoutInterval> queue) {
    for (int i = 0; i < queue.length - 1; i++) {
      queue[i] = queue[i].copyWith(nextIntervalTitle: queue[i + 1].title);
    }
    return queue;
  }
}