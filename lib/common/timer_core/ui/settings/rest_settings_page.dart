import 'package:eland_athletic/common/timer_core/models/interval_audio_haptic_config.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:flutter/material.dart';
import '../../generators/workout_generator.dart';
import '../../controllers/workout_controller.dart';
import '../../models/workout_config.dart';
import '../workouts/workout_page.dart';
import '../../models/workout_phase_summary.dart';
import '../../../strings.dart';
import '../../../widgets/timer_setting_selector.dart';
import '../../../widgets/pill_badge.dart';
import '../../../widgets/primary_action_button.dart';

class RestSettingsPage extends StatefulWidget {
  const RestSettingsPage({super.key});

  @override
  State<RestSettingsPage> createState() => _RestSettingsPageState();
}

class _RestSettingsPageState extends State<RestSettingsPage> {
  int _totalMinutes = 10;
  int _totalSeconds = 0;

  /// Utilities functions
  List<WorkoutConfig> _generateConfigs(){
    final List<List<IntervalAudioConfig>> audioConfigs = [[
      IntervalAudioConfig(audioTrigger: AudioHapticTrigger.start, fileName: 'set_rest.m4a'),
      IntervalAudioConfig(audioTrigger: AudioHapticTrigger.half, fileName: 'half.m4a'),
      IntervalAudioConfig(audioTrigger: AudioHapticTrigger.tenSeconds, fileName: 'ten_seconds.m4a'),
      IntervalAudioConfig(audioTrigger: AudioHapticTrigger.lastThreeSeconds, fileName: 'beep.m4a'),
      IntervalAudioConfig(audioTrigger: AudioHapticTrigger.end, fileName: 'workout_complete.m4a'),
    ]];

    final List<List<IntervalHapticConfig>> hapticConfigs =[[
      IntervalHapticConfig(trigger: AudioHapticTrigger.start, pattern: HapticPattern.heavy),
      IntervalHapticConfig(trigger: AudioHapticTrigger.half, pattern: HapticPattern.doubleTap),
      IntervalHapticConfig(trigger: AudioHapticTrigger.tenSeconds, pattern: HapticPattern.medium),
      IntervalHapticConfig(trigger: AudioHapticTrigger.lastThreeSeconds, pattern: HapticPattern.light),
      IntervalHapticConfig(trigger: AudioHapticTrigger.end, pattern: HapticPattern.heavy),
    ]];

    final List<WorkoutConfig> configs = [
      RestConfig(totalMinutes: _totalMinutes, totalSeconds: _totalSeconds, workoutTitle: ElandStrings.of('timer_rest').toUpperCase(), workoutId: 'rest_qt', phaseTitle: ElandStrings.of('timer_rest').toUpperCase(), phaseSetting: '$_totalMinutes min $_totalSeconds sec', audioConfigs: audioConfigs, hapticConfigs: hapticConfigs ),
    ];

    return configs;
  }

  void _startWorkout() {

    final List<WorkoutConfig> configs = _generateConfigs();
    final generator = WorkoutGenerator();


    final workout = generator.generate(configs);
    final List<WorkoutPhaseSummary> uiPhaseSummary = generator.generateUIPhaseSummary(configs);

    WorkoutController.instance.launchWorkout(workout, uiPhaseSummary);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WorkoutPage()));
  }

  String get _totalWorkoutTime {
    return '${_totalMinutes}M ${_totalSeconds}S';
  }


  /// UI
  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // --- APP BAR ---
      appBar: AppBar(backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          ElandStrings.of('timer_rest').toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),

      // --- BODY ---
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            PillBadge(
              text: '${ElandStrings.of('total_time').toUpperCase()}: $_totalWorkoutTime',
            ),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TimerSettingSelector(
                              label: ElandStrings.of('total_min'),
                              value: _totalMinutes,
                              min: 0,
                              onChanged: (newValue) => setState(() => _totalMinutes = newValue),
                            ),
                            const SizedBox(height: 20),
                            TimerSettingSelector(
                              label: ElandStrings.of('total_sec'),
                              value: _totalSeconds,
                              min: 0,
                              max: 59,
                              onChanged: (newValue) => setState(() => _totalSeconds = newValue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: PrimaryActionButton(
                label: ElandStrings.of('start_btn'),
                onPressed: _startWorkout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}