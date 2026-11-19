import '../../strings.dart';
import 'interval_audio_haptic_config.dart';
import 'timercore_enums.dart';
import 'workout_config.dart';

/// Editable parameter of a [TimerBlock] (used to build the editor UI).
class TimerBlockField {
  final String key;
  final String labelKey;
  final bool inSeconds;
  final int min;
  final int max;

  const TimerBlockField(
    this.key,
    this.labelKey, {
    this.inSeconds = false,
    this.min = 0,
    this.max = 999,
  });

  String get label =>
      inSeconds ? '${ElandStrings.of(labelKey)} (s)' : ElandStrings.of(labelKey);
}

/// One phase of a workout, in a serializable form.
///
/// It is the single source of truth to turn user choices (quick timer pages
/// and custom workouts) into a [WorkoutConfig] with its audio/haptic cues.
class TimerBlock {
  final TimerType type;
  final Map<String, int> params;

  /// Optional custom title (e.g. "Burpees"). Falls back to the timer name.
  final String? name;

  /// Optional notes shown during the phase (e.g. "10 burpees, 15 swing").
  final String? notes;

  const TimerBlock({
    required this.type,
    this.params = const {},
    this.name,
    this.notes,
  });

  /// Timer types a user can add to a workout (preparation is automatic).
  static const List<TimerType> editableTypes = [
    TimerType.tabata,
    TimerType.emom,
    TimerType.amrap,
    TimerType.fortime,
    TimerType.countdown,
    TimerType.rest,
  ];

  static const Map<TimerType, Map<String, int>> defaults = {
    TimerType.tabata: {
      'work': 20,
      'rest': 10,
      'rounds': 8,
      'sets': 1,
      'setRest': 60,
    },
    TimerType.emom: {'roundSeconds': 60, 'rounds': 10},
    TimerType.amrap: {'minutes': 10, 'seconds': 0},
    TimerType.fortime: {'minutes': 10, 'seconds': 0},
    TimerType.countdown: {'minutes': 5, 'seconds': 0},
    TimerType.rest: {'minutes': 1, 'seconds': 0},
  };

  static List<TimerBlockField> fieldsFor(TimerType type) {
    switch (type) {
      case TimerType.tabata:
        return const [
          TimerBlockField('work', 'work_time', inSeconds: true, min: 1),
          TimerBlockField('rest', 'rest_time', inSeconds: true, min: 1),
          // Spoken round cues exist up to round 19 (+ "last round").
          TimerBlockField('rounds', 'round_set', min: 1, max: 20),
          TimerBlockField('sets', 'set_number', min: 1, max: 20),
          TimerBlockField('setRest', 'rest_between_set', inSeconds: true, min: 1),
        ];
      case TimerType.emom:
        return const [
          TimerBlockField('roundSeconds', 'round_duration', inSeconds: true, min: 5),
          TimerBlockField('rounds', 'rounds_label', min: 1, max: 99),
        ];
      case TimerType.fortime:
        return const [
          TimerBlockField('minutes', 'time_cap_min'),
          TimerBlockField('seconds', 'time_cap_sec', max: 59),
        ];
      case TimerType.amrap:
      case TimerType.countdown:
      case TimerType.rest:
        return const [
          TimerBlockField('minutes', 'total_min'),
          TimerBlockField('seconds', 'total_sec', max: 59),
        ];
      case TimerType.preparation:
        return const [];
    }
  }

  factory TimerBlock.defaultsFor(TimerType type) =>
      TimerBlock(type: type, params: Map.of(defaults[type] ?? const {}));

  int param(String key) => params[key] ?? defaults[type]?[key] ?? 0;

  TimerBlock copyWith({
    Map<String, int>? params,
    String? name,
    String? notes,
    bool clearName = false,
    bool clearNotes = false,
  }) {
    return TimerBlock(
      type: type,
      params: params ?? this.params,
      name: clearName ? null : (name ?? this.name),
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }

  TimerBlock withParam(String key, int value) =>
      copyWith(params: {...params, key: value});

  /// Planned duration in seconds (For Time: the time cap).
  int get totalSeconds {
    switch (type) {
      case TimerType.tabata:
        final rounds = param('rounds');
        final sets = param('sets');
        // Each set has (rounds - 1) short rests; sets are separated by a
        // set rest, and there is no rest after the very last round.
        return param('work') * rounds * sets +
            param('rest') * (rounds - 1) * sets +
            param('setRest') * (sets - 1);
      case TimerType.emom:
        return param('roundSeconds') * param('rounds');
      case TimerType.amrap:
      case TimerType.fortime:
      case TimerType.countdown:
      case TimerType.rest:
        return param('minutes') * 60 + param('seconds');
      case TimerType.preparation:
        return 0;
    }
  }

  bool get isValid => totalSeconds > 0;

  String get typeLabel => ElandStrings.of(typeLabelKey(type));

  static String typeLabelKey(TimerType type) => 'timer_${type.name}';

  String get displayTitle =>
      (name?.trim().isNotEmpty ?? false) ? name!.trim() : typeLabel;

  /// Short settings description ("8 R x 3 S", "10 x 60s", "12:00").
  String get settingsLabel {
    switch (type) {
      case TimerType.tabata:
        final base = '${param('work')}s/${param('rest')}s · ${param('rounds')} R';
        return param('sets') > 1 ? '$base x ${param('sets')} S' : base;
      case TimerType.emom:
        return '${param('rounds')} x ${param('roundSeconds')}s';
      case TimerType.amrap:
      case TimerType.fortime:
      case TimerType.countdown:
      case TimerType.rest:
        return formatDuration(totalSeconds);
      case TimerType.preparation:
        return '';
    }
  }

  static String formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  WorkoutConfig toConfig({
    required String workoutId,
    required String workoutTitle,
  }) {
    final title = displayTitle.toUpperCase();
    final cleanNotes = (notes?.trim().isNotEmpty ?? false) ? notes!.trim() : null;

    switch (type) {
      case TimerType.tabata:
        final rounds = param('rounds');
        final sets = param('sets');
        final totalIntervals = rounds * sets * 2 - 1;
        return TabataConfig(
          workSeconds: param('work'),
          restSeconds: param('rest'),
          roundsPerSet: rounds,
          totalSets: sets,
          restBetweenSets: param('setRest'),
          phaseTitle: title,
          phaseSetting: settingsLabel,
          workoutTitle: workoutTitle,
          workoutId: workoutId,
          notes: cleanNotes,
          audioConfigs: _tabataAudio(totalIntervals, rounds),
          hapticConfigs: _tabataHaptics(totalIntervals),
        );
      case TimerType.emom:
        final rounds = param('rounds');
        return EMOMConfig(
          roundDuration: param('roundSeconds'),
          totalMinutes: rounds,
          phaseTitle: title,
          phaseSetting: settingsLabel,
          workoutTitle: workoutTitle,
          workoutId: workoutId,
          notes: cleanNotes,
          audioConfigs: List.generate(
            rounds,
            (i) => [
              const IntervalAudioConfig(
                  audioTrigger: AudioHapticTrigger.start, fileName: 'go.m4a'),
              ..._standardAudio(isLast: i + 1 == rounds),
            ],
          ),
          hapticConfigs: List.generate(
            rounds,
            (i) => _standardHaptics(isLast: i + 1 == rounds),
          ),
        );
      case TimerType.amrap:
        return AMRAPConfig(
          totalMinutes: param('minutes'),
          totalSeconds: param('seconds'),
          phaseTitle: title,
          phaseSetting: settingsLabel,
          workoutTitle: workoutTitle,
          workoutId: workoutId,
          notes: cleanNotes,
          audioConfigs: [_singleAudio('go.m4a')],
          hapticConfigs: [_standardHaptics(isLast: true)],
        );
      case TimerType.fortime:
        return FortimeConfig(
          totalMinutes: param('minutes'),
          totalSeconds: param('seconds'),
          phaseTitle: title,
          phaseSetting: settingsLabel,
          workoutTitle: workoutTitle,
          workoutId: workoutId,
          notes: cleanNotes,
          audioConfigs: [
            [
              ..._singleAudio('go.m4a'),
              const IntervalAudioConfig(
                  audioTrigger: AudioHapticTrigger.overtime,
                  fileName: 'overtime.m4a'),
            ]
          ],
          hapticConfigs: [
            [
              ..._standardHaptics(isLast: true),
              const IntervalHapticConfig(
                  trigger: AudioHapticTrigger.overtime,
                  pattern: HapticPattern.heavy),
            ]
          ],
        );
      case TimerType.countdown:
        return CountdownConfig(
          totalMinutes: param('minutes'),
          totalSeconds: param('seconds'),
          phaseTitle: title,
          phaseSetting: settingsLabel,
          workoutTitle: workoutTitle,
          workoutId: workoutId,
          notes: cleanNotes,
          audioConfigs: [_singleAudio('go.m4a')],
          hapticConfigs: [_standardHaptics(isLast: true)],
        );
      case TimerType.rest:
      case TimerType.preparation:
        return RestConfig(
          totalMinutes: param('minutes'),
          totalSeconds: param('seconds'),
          phaseTitle: title,
          phaseSetting: settingsLabel,
          workoutTitle: workoutTitle,
          workoutId: workoutId,
          notes: cleanNotes,
          audioConfigs: [_singleAudio('set_rest.m4a')],
          hapticConfigs: [_standardHaptics(isLast: true)],
        );
    }
  }

  // --- Audio / haptic cues -------------------------------------------------

  static List<IntervalAudioConfig> _standardAudio({required bool isLast}) => [
        const IntervalAudioConfig(
            audioTrigger: AudioHapticTrigger.half, fileName: 'half.m4a'),
        const IntervalAudioConfig(
            audioTrigger: AudioHapticTrigger.tenSeconds,
            fileName: 'ten_seconds.m4a'),
        const IntervalAudioConfig(
            audioTrigger: AudioHapticTrigger.lastThreeSeconds,
            fileName: 'beep.m4a'),
        if (isLast)
          const IntervalAudioConfig(
              audioTrigger: AudioHapticTrigger.end,
              fileName: 'workout_complete.m4a'),
      ];

  static List<IntervalAudioConfig> _singleAudio(String startFile) => [
        IntervalAudioConfig(
            audioTrigger: AudioHapticTrigger.start, fileName: startFile),
        ..._standardAudio(isLast: true),
      ];

  static List<IntervalHapticConfig> _standardHaptics({required bool isLast}) => [
        const IntervalHapticConfig(
            trigger: AudioHapticTrigger.start, pattern: HapticPattern.heavy),
        const IntervalHapticConfig(
            trigger: AudioHapticTrigger.half, pattern: HapticPattern.doubleTap),
        const IntervalHapticConfig(
            trigger: AudioHapticTrigger.tenSeconds,
            pattern: HapticPattern.medium),
        const IntervalHapticConfig(
            trigger: AudioHapticTrigger.lastThreeSeconds,
            pattern: HapticPattern.light),
        if (isLast)
          const IntervalHapticConfig(
              trigger: AudioHapticTrigger.end, pattern: HapticPattern.heavy),
      ];

  static List<List<IntervalAudioConfig>> _tabataAudio(
      int totalIntervals, int rounds) {
    return List.generate(totalIntervals, (i) {
      final bool isWork = i.isEven;
      final int currentRound = (i ~/ 2) % rounds + 1;
      final bool lastRound = currentRound == rounds;

      return [
        if (i == 0)
          const IntervalAudioConfig(
              audioTrigger: AudioHapticTrigger.start, fileName: 'go.m4a'),
        if (isWork && i > 0 && !lastRound)
          IntervalAudioConfig(
              audioTrigger: AudioHapticTrigger.start,
              fileName: 'round$currentRound.m4a'),
        if (isWork && lastRound && !(i == 0))
          const IntervalAudioConfig(
              audioTrigger: AudioHapticTrigger.start,
              fileName: 'last_round.m4a'),
        if (!isWork && !lastRound)
          const IntervalAudioConfig(
              audioTrigger: AudioHapticTrigger.start, fileName: 'rest.m4a'),
        if (!isWork && lastRound)
          const IntervalAudioConfig(
              audioTrigger: AudioHapticTrigger.start,
              fileName: 'set_rest.m4a'),
        if (isWork)
          const IntervalAudioConfig(
              audioTrigger: AudioHapticTrigger.half, fileName: 'half.m4a'),
        if (isWork)
          const IntervalAudioConfig(
              audioTrigger: AudioHapticTrigger.tenSeconds,
              fileName: 'ten_seconds.m4a'),
        const IntervalAudioConfig(
            audioTrigger: AudioHapticTrigger.lastThreeSeconds,
            fileName: 'beep.m4a'),
        if (i == totalIntervals - 1)
          const IntervalAudioConfig(
              audioTrigger: AudioHapticTrigger.end,
              fileName: 'workout_complete.m4a'),
      ];
    });
  }

  static List<List<IntervalHapticConfig>> _tabataHaptics(int totalIntervals) {
    return List.generate(totalIntervals, (i) {
      final bool isWork = i.isEven;
      return [
        const IntervalHapticConfig(
            trigger: AudioHapticTrigger.start, pattern: HapticPattern.heavy),
        if (isWork)
          const IntervalHapticConfig(
              trigger: AudioHapticTrigger.half,
              pattern: HapticPattern.doubleTap),
        if (isWork)
          const IntervalHapticConfig(
              trigger: AudioHapticTrigger.tenSeconds,
              pattern: HapticPattern.medium),
        const IntervalHapticConfig(
            trigger: AudioHapticTrigger.lastThreeSeconds,
            pattern: HapticPattern.light),
        if (i == totalIntervals - 1)
          const IntervalHapticConfig(
              trigger: AudioHapticTrigger.end, pattern: HapticPattern.heavy),
      ];
    });
  }

  // --- Serialization -------------------------------------------------------

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'params': params,
        if (name != null) 'name': name,
        if (notes != null) 'notes': notes,
      };

  factory TimerBlock.fromJson(Map<String, dynamic> json) {
    final type = TimerType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => TimerType.countdown,
    );
    final rawParams = (json['params'] as Map?) ?? const {};
    return TimerBlock(
      type: type,
      params: {
        for (final e in rawParams.entries)
          if (e.value is num) e.key.toString(): (e.value as num).toInt(),
      },
      name: json['name'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
