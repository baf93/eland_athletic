import '../models/workout_interval.dart';
import '../models/workout_config.dart';
import '../models/workout_phase_summary.dart';

class WorkoutGenerator {
  List<WorkoutInterval> generate(List<WorkoutConfig> sessionConfigs) {
    int totalPhases = sessionConfigs.length;

    final List<WorkoutInterval> finalQueue = sessionConfigs
        .asMap()
        .entries
        .expand((entry) {
      final int currentIndex = entry.key;

      return entry.value.toIntervals(
          currentIndex + 1,
          totalPhases
      );
    }).toList();

    return finalQueue;
  }

  List<WorkoutPhaseSummary> generateUIPhaseSummary(List<WorkoutConfig> sessionConfigs) {
    return sessionConfigs.map((config) {
      return WorkoutPhaseSummary(
        title: config.phaseTitle,
        details: config.phaseSetting,
      );
    }).toList();
  }
}