import 'package:eland_athletic/user_app/timer_core/models/workout_phase_summary.dart';

import '../models/workout_interval.dart';
import '../models/workout_config.dart';

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

  List<WorkoutPhaseSummary> generateUIPhaseSummary(List<WorkoutConfig> sessionConfigs) {
    return sessionConfigs.map((config) {
      return WorkoutPhaseSummary(
        title: config.phaseTitle,
        details: config.phaseSetting,
        isCompleted: false,
      );
    }).toList();
  }
}