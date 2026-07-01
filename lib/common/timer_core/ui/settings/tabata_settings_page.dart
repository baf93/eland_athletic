import 'package:eland_athletic/common/timer_core/models/interval_audio_haptic_config.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../generators/workout_generator.dart';
import '../../controllers/workout_controller.dart';
import '../../models/workout_config.dart';
import '../workouts/workout_page.dart';
import '../../models/workout_phase_summary.dart';
import '../../../eland_responsive.dart';
import '../../../strings.dart';
import '../../../widgets/timer_setting_selector.dart';
import '../../../widgets/pill_badge.dart';
import '../../../widgets/primary_action_button.dart';

class TabataSettingsPage extends StatefulWidget {
  const TabataSettingsPage({super.key});

  @override
  State<TabataSettingsPage> createState() => _TabataSettingsPageState();
}

class _TabataSettingsPageState extends State<TabataSettingsPage> {
  int _workTime = 20;
  int _restTime = 10;
  int _roundSet = 8;
  int _setNumber = 3;
  int _restBetweenSet = 60;

  String get _totalWorkoutTime {
    final int totalSeconds =
        (_workTime + _restTime) * _roundSet * _setNumber +
            (_restBetweenSet * (_setNumber - 1));

    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;

    return '${minutes}M ${seconds > 0 ? '${seconds}S' : ''}';
  }

  List<WorkoutConfig> _generateConfigs() {
    final totalIntervals = (_roundSet * _setNumber * 2) - 1;

    final List<List<IntervalAudioConfig>> audioConfigs = List.generate(
      totalIntervals,
          (i) {
        final bool isWork = i.isEven;
        final int currentRound = (i ~/ 2) % _roundSet + 1;

        return [
          if (i == 0)
            IntervalAudioConfig(
              audioTrigger: AudioHapticTrigger.start,
              fileName: 'go.m4a',
            ),
          if (isWork && i > 0 && currentRound != _roundSet)
            IntervalAudioConfig(
              audioTrigger: AudioHapticTrigger.start,
              fileName: 'round$currentRound.m4a',
            ),
          if (isWork && currentRound == _roundSet)
            IntervalAudioConfig(
              audioTrigger: AudioHapticTrigger.start,
              fileName: 'last_round.m4a',
            ),
          if (!isWork && currentRound != _roundSet)
            IntervalAudioConfig(
              audioTrigger: AudioHapticTrigger.start,
              fileName: 'rest.m4a',
            ),
          if (!isWork && currentRound == _roundSet)
            IntervalAudioConfig(
              audioTrigger: AudioHapticTrigger.start,
              fileName: 'set_rest.m4a',
            ),
          if (isWork)
            IntervalAudioConfig(
              audioTrigger: AudioHapticTrigger.half,
              fileName: 'half.m4a',
            ),
          if (isWork)
            IntervalAudioConfig(
              audioTrigger: AudioHapticTrigger.tenSeconds,
              fileName: 'ten_seconds.m4a',
            ),
          IntervalAudioConfig(
            audioTrigger: AudioHapticTrigger.lastThreeSeconds,
            fileName: 'beep.m4a',
          ),
          if (i == totalIntervals - 1)
            IntervalAudioConfig(
              audioTrigger: AudioHapticTrigger.end,
              fileName: 'workout_complete.m4a',
            ),
        ];
      },
    );

    final List<List<IntervalHapticConfig>> hapticConfigs = List.generate(
      totalIntervals,
          (i) {
        final bool isWork = i.isEven;

        return [
          IntervalHapticConfig(
            trigger: AudioHapticTrigger.start,
            pattern: HapticPattern.heavy,
          ),
          if (isWork)
            IntervalHapticConfig(
              trigger: AudioHapticTrigger.half,
              pattern: HapticPattern.doubleTap,
            ),
          if (isWork)
            IntervalHapticConfig(
              trigger: AudioHapticTrigger.tenSeconds,
              pattern: HapticPattern.medium,
            ),
          IntervalHapticConfig(
            trigger: AudioHapticTrigger.lastThreeSeconds,
            pattern: HapticPattern.light,
          ),
          if (i == totalIntervals - 1)
            IntervalHapticConfig(
              trigger: AudioHapticTrigger.end,
              pattern: HapticPattern.heavy,
            ),
        ];
      },
    );

    return [
      TabataConfig(
        workSeconds: _workTime,
        restSeconds: _restTime,
        roundsPerSet: _roundSet,
        totalSets: _setNumber,
        restBetweenSets: _restBetweenSet,
        phaseTitle: ElandStrings.of('timer_tabata').toUpperCase(),
        phaseSetting: '$_roundSet R x $_setNumber S',
        workoutTitle: ElandStrings.of('timer_tabata').toUpperCase(),
        workoutId: 'tabata_qt',
        audioConfigs: audioConfigs,
        hapticConfigs: hapticConfigs,
      ),
    ];
  }

  void _startWorkout() {
    final configs = _generateConfigs();
    final generator = WorkoutGenerator();

    final workout = generator.generate(configs);
    final uiPhaseSummary = generator.generateUIPhaseSummary(configs);

    WorkoutController.instance.launchWorkout(workout, uiPhaseSummary);

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const WorkoutPage()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.maybePop(context);
          },
        ),
        title: Text(
          ElandStrings.of('timer_tabata').toUpperCase(),
          style: TextStyle(
            fontSize: r.font(18),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: r.pagePadding,
          child: Column(
            children: [
              PillBadge(
                text:
                '${ElandStrings.of('total_time').toUpperCase()}: $_totalWorkoutTime',
              ),

              SizedBox(height: r.compactGap),

              Expanded(
                child: CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TimerSettingSelector(
                            label: '${ElandStrings.of('work_time')} (s)',
                            min: 1,
                            value: _workTime,
                            onChanged: (v) => setState(() => _workTime = v),
                          ),
                          SizedBox(height: r.settingsGap),
                          TimerSettingSelector(
                            label: '${ElandStrings.of('rest_time')} (s)',
                            min: 1,
                            value: _restTime,
                            onChanged: (v) => setState(() => _restTime = v),
                          ),
                          SizedBox(height: r.settingsGap),
                          TimerSettingSelector(
                            label: ElandStrings.of('round_set'),
                            min: 1,
                            max: 20,
                            value: _roundSet,
                            onChanged: (v) => setState(() => _roundSet = v),
                          ),
                          SizedBox(height: r.settingsGap),
                          TimerSettingSelector(
                            label: ElandStrings.of('set_number'),
                            min: 1,
                            value: _setNumber,
                            onChanged: (v) => setState(() => _setNumber = v),
                          ),
                          SizedBox(height: r.settingsGap),
                          TimerSettingSelector(
                            label: '${ElandStrings.of('rest_between_set')} (s)',
                            min: 1,
                            value: _restBetweenSet,
                            onChanged: (v) =>
                                setState(() => _restBetweenSet = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: r.bottomButtonPadding,
                child: PrimaryActionButton(
                  height: r.primaryButtonHeight,
                  label: ElandStrings.of('start_btn'),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _startWorkout();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}