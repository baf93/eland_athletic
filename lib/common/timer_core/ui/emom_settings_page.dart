import 'package:eland_athletic/user_app/timer_core/models/workout_phase_summary.dart';
import 'package:flutter/material.dart';
import '../generators/workout_generator.dart';
import '../controllers/workout_controller.dart';
import '../models/workout_config.dart';
import 'workout_page.dart';
import '../../../common/strings.dart';
import '../../../common/widgets/timer_setting_selector.dart';

class EMOMSettingsPage extends StatefulWidget {
  const EMOMSettingsPage({super.key});

  @override
  State<EMOMSettingsPage> createState() => _EMOMSettingsPageState();
}

class _EMOMSettingsPageState extends State<EMOMSettingsPage> {
  int _totalMinutes = 10;

  /// Utilities functions
  void _startWorkout() {

    final List<WorkoutConfig> configs = [
      EMOMConfig(workoutTitle: ElandStrings.of('timer_emom').toUpperCase(), workoutId: 'emom_qt', totalMinutes: _totalMinutes, phaseTitle: ElandStrings.of('timer_emom').toUpperCase(), phaseSetting: '${_totalMinutes} min' ),
    ];

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