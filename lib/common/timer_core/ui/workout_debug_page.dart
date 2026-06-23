import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/workout_controller.dart';
import '../providers/timer_provider.dart';
import '../models/timercore_enums.dart';

class WorkoutPage extends ConsumerStatefulWidget {
  const WorkoutPage({super.key});

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> {
  final ExpansionTileController _expansionController = ExpansionTileController();

  @override
  void initState() {
    super.initState();
    // Richiesta stato iniziale una sola volta dopo il primo frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WorkoutController.instance.requestStatus();
      _expansionController.expand();
    });
  }

  String _formatTime(int s) {
    final absS = s.abs();
    return '${(absS ~/ 60).toString().padLeft(2, '0')}:${(absS % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Debug Workout"),
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- UI PRINCIPALE ---
            Text(
              timerState.currentIntervalTitle.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              _formatTime(timerState.remainingSeconds),
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),

            const SizedBox(height: 30),

            // --- TABELLA DETTAGLI COMPLETA ---
            Card(
              elevation: 2,
              child: ExpansionTile(
                controller: _expansionController,
                initiallyExpanded: true,
                title: const Text("Stato Completo TimerState"),
                children: [
                  _buildDebugRow("Workout ID", timerState.workoutId),
                  _buildDebugRow("Title", timerState.workoutTitle),
                  _buildDebugRow("Status", timerState.status.name),
                  _buildDebugRow("Phase Index", "${timerState.currentPhaseIndex}/${timerState.totalPhases}"),
                  _buildDebugRow("Round Index", "${timerState.currentRound}/${timerState.totalRound}"),
                  _buildDebugRow("Is Last Phase", timerState.isLastPhase.toString()),
                  _buildDebugRow("Interval Type", timerState.intervalType.name),
                  _buildDebugRow("Timer Type", timerState.timerType.name),
                  _buildDebugRow("Progress", "${(timerState.intervalProgress * 100).toStringAsFixed(1)}%"),
                  _buildDebugRow("Notes", timerState.currentIntervalNotes ?? "N/A"),
                  _buildDebugRow("Phase Summary Count", timerState.workoutPhaseSummary.length.toString()),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Raw Phase Summary: ${timerState.workoutPhaseSummary.toString()}",
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- CONTROLLI ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bottone Play/Pause Dinamico
                _actionButton(
                  timerState.status == TimerStatus.running ? Icons.pause : Icons.play_arrow,
                  colorScheme.primary,
                      () {
                    if (timerState.status == TimerStatus.running) {
                      WorkoutController.instance.pauseWorkout();
                    } else {
                      WorkoutController.instance.resumeWorkout();
                    }
                  },
                ),
                const SizedBox(width: 20),
                // Bottone Stop
                _actionButton(
                  Icons.stop_circle,
                  colorScheme.error,
                      () {
                    WorkoutController.instance.stopWorkout();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 48,
      style: IconButton.styleFrom(backgroundColor: color),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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