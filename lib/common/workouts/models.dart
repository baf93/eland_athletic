import 'dart:math';

import '../timer_core/models/timer_block.dart';
import '../timer_core/models/workout_config.dart';

String generateId() {
  final rnd = Random();
  final now = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final suffix = List.generate(6, (_) => rnd.nextInt(36).toRadixString(36)).join();
  return '$now$suffix';
}

/// Weekly reminder to do a workout ("Mon, Wed, Fri at 18:30").
class WorkoutReminder {
  final bool enabled;

  /// ISO weekdays: 1 = Monday ... 7 = Sunday.
  final List<int> weekdays;
  final int hour;
  final int minute;

  const WorkoutReminder({
    this.enabled = true,
    this.weekdays = const [],
    this.hour = 18,
    this.minute = 0,
  });

  bool get isActive => enabled && weekdays.isNotEmpty;

  WorkoutReminder copyWith({
    bool? enabled,
    List<int>? weekdays,
    int? hour,
    int? minute,
  }) {
    return WorkoutReminder(
      enabled: enabled ?? this.enabled,
      weekdays: weekdays ?? this.weekdays,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'weekdays': weekdays,
        'hour': hour,
        'minute': minute,
      };

  factory WorkoutReminder.fromJson(Map<String, dynamic> json) {
    final days = (json['weekdays'] as List? ?? const [])
        .whereType<num>()
        .map((d) => d.toInt())
        .where((d) => d >= 1 && d <= 7)
        .toSet()
        .toList()
      ..sort();
    return WorkoutReminder(
      enabled: json['enabled'] as bool? ?? true,
      weekdays: days,
      hour: ((json['hour'] as num?)?.toInt() ?? 18).clamp(0, 23),
      minute: ((json['minute'] as num?)?.toInt() ?? 0).clamp(0, 59),
    );
  }
}

/// A workout saved by the user: an ordered list of timer blocks.
class CustomWorkout {
  final String id;
  final String name;
  final String? notes;
  final List<TimerBlock> blocks;
  final WorkoutReminder? reminder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomWorkout({
    required this.id,
    required this.name,
    this.notes,
    required this.blocks,
    this.reminder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomWorkout.create({
    required String name,
    required List<TimerBlock> blocks,
    String? notes,
  }) {
    final now = DateTime.now();
    return CustomWorkout(
      id: generateId(),
      name: name,
      notes: notes,
      blocks: blocks,
      createdAt: now,
      updatedAt: now,
    );
  }

  int get totalSeconds => blocks.fold(0, (sum, b) => sum + b.totalSeconds);

  bool get isValid =>
      name.trim().isNotEmpty && blocks.isNotEmpty && blocks.every((b) => b.isValid);

  CustomWorkout copyWith({
    String? name,
    String? notes,
    List<TimerBlock>? blocks,
    WorkoutReminder? reminder,
    bool clearReminder = false,
    DateTime? updatedAt,
  }) {
    return CustomWorkout(
      id: id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      blocks: blocks ?? this.blocks,
      reminder: clearReminder ? null : (reminder ?? this.reminder),
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  List<WorkoutConfig> toConfigs() => [
        for (final block in blocks)
          block.toConfig(workoutId: id, workoutTitle: name.toUpperCase()),
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (notes != null) 'notes': notes,
        'blocks': blocks.map((b) => b.toJson()).toList(),
        if (reminder != null) 'reminder': reminder!.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory CustomWorkout.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return CustomWorkout(
      id: json['id'] as String? ?? generateId(),
      name: json['name'] as String? ?? '',
      notes: json['notes'] as String?,
      blocks: (json['blocks'] as List? ?? const [])
          .whereType<Map>()
          .map((b) => TimerBlock.fromJson(Map<String, dynamic>.from(b)))
          .toList(),
      reminder: json['reminder'] is Map
          ? WorkoutReminder.fromJson(
              Map<String, dynamic>.from(json['reminder'] as Map))
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? now,
    );
  }
}

/// Result of a single For Time phase.
class ForTimeResult {
  final String title;
  final int seconds;
  final int capSeconds;

  const ForTimeResult({
    required this.title,
    required this.seconds,
    required this.capSeconds,
  });

  bool get overCap => capSeconds > 0 && seconds > capSeconds;

  Map<String, dynamic> toJson() => {
        'title': title,
        'seconds': seconds,
        'capSeconds': capSeconds,
      };

  factory ForTimeResult.fromJson(Map<String, dynamic> json) => ForTimeResult(
        title: json['title'] as String? ?? '',
        seconds: (json['seconds'] as num?)?.toInt() ?? 0,
        capSeconds: (json['capSeconds'] as num?)?.toInt() ?? 0,
      );
}

/// A completed workout, as stored in the history.
class WorkoutLog {
  final String id;

  /// Id of the custom workout, or of the quick timer (e.g. "tabata_qt").
  final String workoutId;
  final String title;
  final DateTime completedAt;

  /// Training time without preparation and pauses.
  final int activeSeconds;

  /// Phase descriptions, e.g. ["TABATA · 20s/10s · 8 R"].
  final List<String> phases;
  final int? amrapRounds;
  final List<ForTimeResult> forTimeResults;
  final String? note;

  const WorkoutLog({
    required this.id,
    required this.workoutId,
    required this.title,
    required this.completedAt,
    required this.activeSeconds,
    this.phases = const [],
    this.amrapRounds,
    this.forTimeResults = const [],
    this.note,
  });

  WorkoutLog copyWith({String? note}) => WorkoutLog(
        id: id,
        workoutId: workoutId,
        title: title,
        completedAt: completedAt,
        activeSeconds: activeSeconds,
        phases: phases,
        amrapRounds: amrapRounds,
        forTimeResults: forTimeResults,
        note: note ?? this.note,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'workoutId': workoutId,
        'title': title,
        'completedAt': completedAt.toIso8601String(),
        'activeSeconds': activeSeconds,
        'phases': phases,
        if (amrapRounds != null) 'amrapRounds': amrapRounds,
        if (forTimeResults.isNotEmpty)
          'forTimeResults': forTimeResults.map((r) => r.toJson()).toList(),
        if (note != null) 'note': note,
      };

  factory WorkoutLog.fromJson(Map<String, dynamic> json) => WorkoutLog(
        id: json['id'] as String? ?? generateId(),
        workoutId: json['workoutId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ??
            DateTime.now(),
        activeSeconds: (json['activeSeconds'] as num?)?.toInt() ?? 0,
        phases: (json['phases'] as List? ?? const [])
            .map((p) => p.toString())
            .toList(),
        amrapRounds: (json['amrapRounds'] as num?)?.toInt(),
        forTimeResults: (json['forTimeResults'] as List? ?? const [])
            .whereType<Map>()
            .map((r) => ForTimeResult.fromJson(Map<String, dynamic>.from(r)))
            .toList(),
        note: json['note'] as String?,
      );
}
