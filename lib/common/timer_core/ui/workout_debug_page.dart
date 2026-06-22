import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/workout_controller.dart';
import '../providers/timer_provider.dart';
import '../models/timercore_enums.dart';

class WorkoutPage extends ConsumerWidget {
  const WorkoutPage({super.key});

  String _formatTime(int s) {
    final absS = s.abs();
    return '${(absS ~/ 60).toString().padLeft(2, '0')}:${(absS % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    WorkoutController.instance.requestStatus();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Debug Workout"),
        backgroundColor: colorScheme.surfaceVariant,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- UI PRINCIPALE (Visualizzazione pulita) ---
            Text(timerState.currentIntervalTitle.toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text(_formatTime(timerState.remainingSeconds), style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 20),

            // --- SEZIONE DEBUG (Tutte le info del timerState) ---
            ExpansionTile(
              title: const Text("Dati TimerState (Debug)"),
              subtitle: const Text("Espandi per vedere lo stato completo"),
              children: [
                _buildDebugRow("Workout ID", timerState.workoutId),
                _buildDebugRow("Workout Title", timerState.workoutTitle),
                _buildDebugRow("Status", timerState.status.name),
                _buildDebugRow("Remaining Seconds", timerState.remainingSeconds.toString()),
                _buildDebugRow("Phase", "${timerState.currentPhaseIndex + 1}/${timerState.totalPhases}"),
                _buildDebugRow("Is Last Phase", timerState.isLastPhase.toString()),
                _buildDebugRow("Interval Type", timerState.intervalType.name),
                _buildDebugRow("Timer Type", timerState.timerType.name),
                _buildDebugRow("Progress", (timerState.intervalProgress * 100).toStringAsFixed(1) + "%"),
                _buildDebugRow("Current Interval Title", timerState.currentIntervalTitle),
                _buildDebugRow("Notes", timerState.currentIntervalNotes ?? "N/A"),
                _buildDebugRow("Workout Phase Summary", timerState.workoutPhaseSummary.toString())
              ],
            ),




            const SizedBox(height: 40),

            // --- CONTROLLI ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () => WorkoutController.instance.pauseWorkout(),
                    child: const Text("Pause")),
                const SizedBox(width: 20),
                ElevatedButton(
                    onPressed: () => WorkoutController.instance.resumeWorkout(),
                    child: const Text("Resume")),
                const SizedBox(width: 20),
                ElevatedButton(
                    onPressed: () {
                      WorkoutController.instance.stopWorkout();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: colorScheme.error),
                    child: const Text("Stop")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }
}