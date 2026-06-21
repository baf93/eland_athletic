import '../model/workout_interval.dart';
import '../model/workout_config.dart';

class WorkoutGenerator {
  List<WorkoutInterval> generate(List<WorkoutConfig> sessionConfigs) {
    int totalPhases = sessionConfigs.length;

    final List<WorkoutInterval> finalQueue = sessionConfigs
        .asMap()
        .entries
        .expand((entry) {
      final int currentIndex = entry.key;
      final int nextIndex = currentIndex + 1;

      final bool hasNext = nextIndex < sessionConfigs.length;

      final String nextTitle = hasNext
          ? sessionConfigs[nextIndex].phaseTitle
          : "";
      final String nextSetting = hasNext
          ? sessionConfigs[nextIndex].phaseSetting
          : "";

      return entry.value.toIntervals(
          currentIndex + 1,
          totalPhases,
          nextTitle,
          nextSetting
      );
    }).toList();

    return finalQueue;
  }
}