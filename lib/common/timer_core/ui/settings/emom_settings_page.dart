import 'package:eland_athletic/common/timer_core/models/interval_audio_haptic_config.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../generators/workout_generator.dart';
import '../../controllers/workout_controller.dart';
import '../../models/workout_config.dart';
import '../workouts/workout_page.dart';
import '../../models/workout_phase_summary.dart';
import '../../../strings.dart';
import '../../../widgets/timer_setting_selector.dart';
import '../../../widgets/pill_badge.dart';
import '../../../widgets/primary_action_button.dart';

class EMOMSettingsPage extends StatefulWidget {
  const EMOMSettingsPage({super.key});

  @override
  State<EMOMSettingsPage> createState() => _EMOMSettingsPageState();
}

class _EMOMSettingsPageState extends State<EMOMSettingsPage> {
  int _totalMinutes = 10;
  int _roundDuration = 60;

  /// Utilities functions
  List<WorkoutConfig> _generateConfigs(){
    final List<List<IntervalAudioConfig>> audioConfigs = List.generate(_totalMinutes,
            (i) => [
          IntervalAudioConfig(audioTrigger: AudioHapticTrigger.start, fileName: 'go.m4a'),
          IntervalAudioConfig(audioTrigger: AudioHapticTrigger.half, fileName: 'half.m4a'),
          IntervalAudioConfig(audioTrigger: AudioHapticTrigger.tenSeconds, fileName: 'ten_seconds.m4a'),
          IntervalAudioConfig(audioTrigger: AudioHapticTrigger.lastThreeSeconds, fileName: 'beep.m4a'),
          if(i+1 == _totalMinutes) IntervalAudioConfig(audioTrigger: AudioHapticTrigger.end, fileName: 'workout_complete.m4a'),
        ]
    );

    final List<List<IntervalHapticConfig>> hapticConfigs = List.generate(_totalMinutes,
            (i) => [
          IntervalHapticConfig(trigger: AudioHapticTrigger.start, pattern: HapticPattern.heavy),
          IntervalHapticConfig(trigger: AudioHapticTrigger.half, pattern: HapticPattern.doubleTap),
          IntervalHapticConfig(trigger: AudioHapticTrigger.tenSeconds, pattern: HapticPattern.medium),
          IntervalHapticConfig(trigger: AudioHapticTrigger.lastThreeSeconds, pattern: HapticPattern.light),
          if(i+1 == _totalMinutes) IntervalHapticConfig(trigger: AudioHapticTrigger.end, pattern: HapticPattern.heavy),
        ]
    );


    final List<WorkoutConfig> configs = [
      EMOMConfig(roundDuration: _roundDuration, workoutTitle: ElandStrings.of('timer_emom').toUpperCase(), workoutId: 'emom_qt', totalMinutes: _totalMinutes, phaseTitle: ElandStrings.of('timer_emom').toUpperCase(), phaseSetting: '$_totalMinutes min', audioConfigs: audioConfigs, hapticConfigs: hapticConfigs ),
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
    final int totalSeconds = _totalMinutes * _roundDuration;

    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;

    return '${minutes}M ${seconds > 0 ? '${seconds}S' : ''}';
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
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.maybePop(context);
          },
        ),
        title: Text(
          ElandStrings.of('timer_emom').toUpperCase(),
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
                                label: '${ElandStrings.of('round_duration')} (s)',
                                value: _roundDuration,
                                onChanged: (newValue) => setState(() => _roundDuration = newValue)
                            ),
                            const SizedBox(height: 20),
                            TimerSettingSelector(
                              label: ElandStrings.of('total_min'),
                              value: _totalMinutes,
                              min: 1,
                              max: 60,
                              onChanged: (newValue) => setState(() => _totalMinutes = newValue),
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
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _startWorkout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}