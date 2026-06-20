class WorkoutPhaseSummary {
  final String title;
  final String details;
  final bool isCompleted;

  const WorkoutPhaseSummary({
    required this.title,
    required this.details,
    this.isCompleted = false
  });
}