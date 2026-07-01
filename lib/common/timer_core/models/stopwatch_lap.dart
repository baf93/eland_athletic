class StopWatchLap {
  final int lapTimeMs;

  const StopWatchLap({
    required this.lapTimeMs,
  });

  factory StopWatchLap.fromJson(Map<String, dynamic> json) {
    return StopWatchLap(
      lapTimeMs: json['lapTimeMs'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'lapTimeMs': lapTimeMs,
  };

  @override
  String toString() {
    return '{lapTimeMs: $lapTimeMs}';
  }
}