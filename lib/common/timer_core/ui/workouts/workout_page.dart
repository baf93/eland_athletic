import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/workout_controller.dart';
import '../../providers/timer_provider.dart';
import '../../models/timercore_enums.dart';
import '../../../widgets/progress_bar.dart';
// Importa i tuoi widget dinamici
import 'amrap_workout.dart';
import 'countdown_workout.dart';
import 'emom_workout.dart';
import 'fortime_workout.dart';
import 'rest_workout.dart';
import 'tabata_workout.dart';
import 'prepare_workout.dart';
import '../../models/timer_state.dart';
import '../../models/timercore_enums.dart';

class WorkoutPage extends ConsumerWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Nero OLED
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER (Freccia indietro + Nome Workout)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timerState.workoutTitle.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            // 2. BODY DINAMICO (Carica il widget in base al tipo di workout)
            Expanded(
              child: Center(
                child: _buildWorkoutSpecificBody(timerState),
              ),
            ),

            // 3. BOTTOM (Controlli + Linea Fasi)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _elandActionButton(Icons.skip_next, () => WorkoutController.instance.skipPhase()),
                      const SizedBox(width: 25),
                      _elandActionButton(
                        timerState.status == TimerStatus.running ? Icons.pause : Icons.play_arrow,
                            () => timerState.status == TimerStatus.running
                            ? WorkoutController.instance.pauseWorkout()
                            : WorkoutController.instance.resumeWorkout(),
                      ),
                      const SizedBox(width: 25),
                      _elandActionButton(Icons.close, () {
                        WorkoutController.instance.stopWorkout();
                        Navigator.of(context).pop();
                      }),
                    ],
                  ),
                ),

                // Footer Fasi
                ElandSegmentedProgressBar(
                  totalSegments: timerState.totalPhases,
                  currentSegment: timerState.currentPhaseIndex,
                  onTap: () => _openPhaseSummary(context, timerState),
                ),
              ],
            ),
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
  Widget _elandActionButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 65, height: 65,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 1)),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

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