import 'package:eland_athletic/common/timer_core/models/interval_audio_haptic_config.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:flutter/material.dart';
import '../generators/workout_generator.dart';
import '../controllers/workout_controller.dart';
import '../models/workout_config.dart';
import 'workout_debug_page.dart'; // Assicurati che sia importata la pagina corretta
import '../models/workout_phase_summary.dart';
import '../../../common/strings.dart';
import '../../../common/widgets/timer_setting_selector.dart';
import '../../../common/widgets/pill_badge.dart';

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

  /// Calcolo del tempo totale per il Tabata
  String get _totalWorkoutTime {
    final int totalSeconds = (_workTime + _restTime) * _roundSet * _setNumber +
        (_restBetweenSet * (_setNumber - 1));

    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;

    return '${minutes}M ${seconds > 0 ? '${seconds}S' : ''}';
  }

  /// Genera le configurazioni per il Tabata
  List<WorkoutConfig> _generateConfigs() {
    // Il Tabata totale è (Round * Set) * 2 (Work + Rest)
    final totalIntervals = _roundSet * _setNumber * 2;

    final List<List<IntervalAudioConfig>> audioConfigs = List.generate(totalIntervals, (i) {
      bool isWork = i.isEven; // 0, 2, 4... sono Lavoro; 1, 3, 5... sono Riposo

      // Configurazione specifica per Lavoro o Riposo
      return [
        if (isWork) IntervalAudioConfig(audioTrigger: AudioHapticTrigger.start, fileName: 'go.m4a'),
        // ... aggiungi qui altri trigger (half, tenSeconds, ecc.)
        if (i == totalIntervals - 1)
          IntervalAudioConfig(audioTrigger: AudioHapticTrigger.end, fileName: 'workout_complete.m4a'),
      ];
    });

    final List<List<IntervalHapticConfig>> hapticConfigs = List.generate(totalIntervals, (i) {
      bool isWork = i.isEven;
      return [
        if (isWork) IntervalHapticConfig(trigger: AudioHapticTrigger.start, pattern: HapticPattern.heavy),
        if (i == totalIntervals - 1)
          IntervalHapticConfig(trigger: AudioHapticTrigger.end, pattern: HapticPattern.heavy),
      ];
    });

    return [
      TabataConfig(
        workSeconds: _workTime,
        restSeconds: _restTime,
        roundsPerSet: _roundSet,
        totalSets: _setNumber,
        restBetweenSetsSeconds: _restBetweenSet,
        phaseTitle: ElandStrings.of('timer_tabata').toUpperCase(),
        phaseSetting: '$_roundSet R x $_setNumber S',
        workoutTitle: ElandStrings.of('timer_tabata').toUpperCase(),
        workoutId: 'tabata_qt',
        audioConfigs: audioConfigs, // Ora questa è List<List<...>> come richiesto
        hapticConfigs: hapticConfigs,
      ),
    ];
  }

  void _startWorkout() {
    final List<WorkoutConfig> configs = _generateConfigs();
    final generator = WorkoutGenerator();

    final workout = generator.generate(configs);
    final List<WorkoutPhaseSummary> uiPhaseSummary = generator.generateUIPhaseSummary(configs);

    WorkoutController.instance.launchWorkout(workout, uiPhaseSummary);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WorkoutPage()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          ElandStrings.of('timer_tabata').toUpperCase(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PillBadge(
                    text: '${ElandStrings.of('total_time').toUpperCase()}: $_totalWorkoutTime',
                  ),
                  const SizedBox(height: 30),
                  TimerSettingSelector(label: '${ElandStrings.of('work_time')} (s)', min: 1, value: _workTime, onChanged: (v) => setState(() => _workTime = v)),
                  const SizedBox(height: 20),
                  TimerSettingSelector(label: '${ElandStrings.of('rest_time')} (s)', min: 1, value: _restTime, onChanged: (v) => setState(() => _restTime = v)),
                  const SizedBox(height: 20),
                  TimerSettingSelector(label: ElandStrings.of('round_set'), min: 1, max: 20, value: _roundSet, onChanged: (v) => setState(() => _roundSet = v)),
                  const SizedBox(height: 20),
                  TimerSettingSelector(label: ElandStrings.of('set_number'), min: 1, value: _setNumber, onChanged: (v) => setState(() => _setNumber = v)),
                  const SizedBox(height: 20),
                  TimerSettingSelector(label: '${ElandStrings.of('rest_between_set')} (s)', min: 1, value: _restBetweenSet, onChanged: (v) => setState(() => _restBetweenSet = v)),

                  const SizedBox(height: 40),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _startWorkout,
                      child: Text(
                        ElandStrings.of('start_btn').toUpperCase(),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}