import 'package:eland_athletic/common/timer_core/models/interval_audio_haptic_config.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:flutter/material.dart';
import '../generators/workout_generator.dart';
import '../controllers/workout_controller.dart';
import '../models/workout_config.dart';
import 'workout_debug_page.dart';
import '../models/workout_phase_summary.dart';
import '../../../common/strings.dart';
import '../../../common/widgets/timer_setting_selector.dart';

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TimerSettingSelector(label: '${ElandStrings.of('round_duration')} (s)', value: _roundDuration, onChanged: (newValue) {
                    setState(() => _roundDuration = newValue);
                  }),
                  const SizedBox(height: 20),
                  TimerSettingSelector(
                    label: ElandStrings.of('total_min'),
                    value: _totalMinutes,
                    min: 1,
                    max: 60,
                    onChanged: (newValue) {
                      setState(() => _totalMinutes = newValue);
                    },
                  ),

                  const SizedBox(height: 80),

                  // Start button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _startWorkout,
                      child: Text(
                        ElandStrings.of('start_btn').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}