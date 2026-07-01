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

class AmrapSettingsPage extends StatefulWidget {
  const AmrapSettingsPage({super.key});

  @override
  State<AmrapSettingsPage> createState() => _AmrapSettingsPageState();
}

class _AmrapSettingsPageState extends State<AmrapSettingsPage> {
  int _totalMinutes = 10;
  int _totalSeconds = 0;

  List<WorkoutConfig> _generateConfigs() {
    final List<List<IntervalAudioConfig>> audioConfigs = [
      [
        IntervalAudioConfig(audioTrigger: AudioHapticTrigger.start, fileName: 'go.m4a'),
        IntervalAudioConfig(audioTrigger: AudioHapticTrigger.half, fileName: 'half.m4a'),
        IntervalAudioConfig(audioTrigger: AudioHapticTrigger.tenSeconds, fileName: 'ten_seconds.m4a'),
        IntervalAudioConfig(audioTrigger: AudioHapticTrigger.lastThreeSeconds, fileName: 'beep.m4a'),
        IntervalAudioConfig(audioTrigger: AudioHapticTrigger.end, fileName: 'workout_complete.m4a'),
      ],
    ];

    final List<List<IntervalHapticConfig>> hapticConfigs = [
      [
        IntervalHapticConfig(trigger: AudioHapticTrigger.start, pattern: HapticPattern.heavy),
        IntervalHapticConfig(trigger: AudioHapticTrigger.half, pattern: HapticPattern.doubleTap),
        IntervalHapticConfig(trigger: AudioHapticTrigger.tenSeconds, pattern: HapticPattern.medium),
        IntervalHapticConfig(trigger: AudioHapticTrigger.lastThreeSeconds, pattern: HapticPattern.light),
        IntervalHapticConfig(trigger: AudioHapticTrigger.end, pattern: HapticPattern.heavy),
      ],
    ];

    return [
      AMRAPConfig(
        totalMinutes: _totalMinutes,
        totalSeconds: _totalSeconds,
        workoutTitle: ElandStrings.of('timer_amrap').toUpperCase(),
        workoutId: 'amrap_qt',
        phaseTitle: ElandStrings.of('timer_amrap').toUpperCase(),
        phaseSetting: '$_totalMinutes min $_totalSeconds sec',
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

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WorkoutPage()),
    );
  }

  String get _totalWorkoutTime {
    return '${_totalMinutes}M ${_totalSeconds}S';
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
          ElandStrings.of('timer_amrap').toUpperCase(),
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
                            label: ElandStrings.of('total_min'),
                            value: _totalMinutes,
                            min: 0,
                            onChanged: (newValue) =>
                                setState(() => _totalMinutes = newValue),
                          ),
                          SizedBox(height: r.settingsGap),
                          TimerSettingSelector(
                            label: ElandStrings.of('total_sec'),
                            value: _totalSeconds,
                            min: 0,
                            max: 59,
                            onChanged: (newValue) =>
                                setState(() => _totalSeconds = newValue),
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