class WorkoutPhaseSummary {
  final String title;
  final String details;

  const WorkoutPhaseSummary({
    required this.title,
    required this.details,
  });

  factory WorkoutPhaseSummary.fromJson(Map<String, dynamic> json) {
    return WorkoutPhaseSummary(
      title: json['title'] as String,
      details: json['details'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'details': details,
  };

  @override
  String toString() {
    return '{title: $title, details: $details}';
  }
}