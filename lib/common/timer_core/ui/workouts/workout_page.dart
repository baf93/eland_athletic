import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/workout_controller.dart';
import '../../providers/timer_provider.dart';
import '../../models/timercore_enums.dart';
import '../../../widgets/progress_bar.dart';
import '../../models/timer_state.dart';
import '../../models/timercore_enums.dart';
import '../../../strings.dart';
import '../../../widgets/eland_action_button.dart';
// Runners Widgets
import 'amrap_workout.dart';
import 'countdown_workout.dart';
import 'emom_workout.dart';
import 'fortime_workout.dart';
import 'rest_workout.dart';
import 'tabata_workout.dart';
import 'prepare_workout.dart';


class WorkoutPage extends ConsumerWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Nero OLED
      // --- APP BAR ---
      appBar: AppBar(backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          timerState.workoutTitle.toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [


            /// --- APP BAR ---




            // 2. BODY DINAMICO (Carica il widget in base al tipo di workout)
            Expanded(
              child: Center(
                child:
                  AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _buildWorkoutSpecificBody(timerState), // Il tuo widget dinamico
                  // IMPORTANTE: Assicurati che i widget figli abbiano Key univoche!
                ),
              ),
            ),

          ],
        ),
      ),
      // FOOTER FISSO
// Sostituisci persistentFooterButtons con questo:
      bottomNavigationBar: Container(
        color: theme.scaffoldBackgroundColor, // O il tuo colore di sfondo
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        child: Column(

          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 1, color: Colors.white10),
            const SizedBox(height: 20),
            // I tuoi controlli
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElandActionButton(
                  icon: Icons.skip_next_rounded,
                  onPressed: () => WorkoutController.instance.skipPhase(),
                  iconColor: Colors.blue,
                  borderColor: Colors.blue,
                  size: 75,
                ),
                const SizedBox(width: 40),
                ElandActionButton(
                  icon: timerState.status == TimerStatus.running ? Icons.pause : Icons.play_arrow,
                  onPressed: () => timerState.status == TimerStatus.running
                      ? WorkoutController.instance.pauseWorkout()
                      : WorkoutController.instance.resumeWorkout(),
                  iconColor: timerState.status == TimerStatus.running ? Colors.yellow : Colors.green,
                  borderColor: timerState.status == TimerStatus.running ? Colors.yellow : Colors.green,
                  size: 75,
                ),
                const SizedBox(width: 40),

                ElandActionButton(
                  icon: Icons.close_rounded,
                  onPressed: () => WorkoutController.instance.stopWorkout(),
                  iconColor: Colors.red,
                  borderColor: Colors.red,
                  size: 75,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Footer Fasi
            ElandSegmentedProgressBar(
              totalSegments: timerState.totalPhases,
              currentSegment: timerState.currentPhaseIndex,
              onTap: () => _openPhaseSummary(context, timerState),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  // --- LOGICA CARICAMENTO DINAMICO ---
  Widget _buildWorkoutSpecificBody(TimerState timerState) {
    switch (timerState.timerType) {
      case TimerType.tabata:
        return TabataWorkoutWidget(timerState: timerState);
      case TimerType.emom:
        return EmomWorkoutWidget(timerState: timerState);
      case TimerType.fortime:
        return FortimeWorkoutWidget(timerState: timerState);
      case TimerType.rest:
        return RestWorkoutWidget(timerState: timerState);
      case TimerType.amrap:
        return AmrapWorkoutWidget(timerState: timerState);
      case TimerType.countdown:
        return CountdownWorkoutWidget(timerState: timerState);
      case TimerType.preparation:
        return PrepareWorkoutWidget(timerState: timerState);
      default:
        return const Center(child: Text("Workout non definito", style: TextStyle(color: Colors.white)));
    }
  }

  // --- COMPONENTI ---
  void _openPhaseSummary(BuildContext context, timerState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Color(0xFF121212), // Grigio scuro per contrasto col nero OLED
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(margin: const EdgeInsets.only(top: 12, bottom: 20), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: timerState.workoutPhaseSummary.length,
                itemBuilder: (context, index) {
                  final summary = timerState.workoutPhaseSummary[index];
                  bool isCurrent = index == timerState.currentPhaseIndex;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("FASE ${index + 1}", style: TextStyle(color: isCurrent ? Colors.white : Colors.white30, fontSize: 16)),
                        Text(summary.title, style: TextStyle(color: isCurrent ? const Color(0xFFE69138) : Colors.white60, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}