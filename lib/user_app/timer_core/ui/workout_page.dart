import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../workout_controller.dart';
import '../../providers/timer_provider.dart';
import '../model/timer_enums.dart';

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

    ref.listen(timerProvider, (previous, next) {
      if (next.status == TimerStatus.completed) {
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timerState.currentIntervalTitle.toUpperCase(),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 50),
              // Cerchio di Progresso
              SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: timerState.intervalProgress,
                      strokeWidth: 10,
                      color: colorScheme.primary,
                      backgroundColor: colorScheme.outline.withOpacity(0.2),
                    ),
                    Text(
                      _formatTime(timerState.remainingSeconds),
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              // Controlli
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 64,
                    icon: Icon(timerState.status == TimerStatus.paused
                        ? Icons.play_arrow
                        : Icons.pause),
                    onPressed: () {
                      timerState.status == TimerStatus.paused
                          ? WorkoutController.instance.resumeWorkout()
                          : WorkoutController.instance.pauseWorkout();
                    },
                  ),
                  const SizedBox(width: 40),
                  IconButton(
                    iconSize: 64,
                    icon: const Icon(Icons.stop),
                    color: colorScheme.error,
                    onPressed: () {
                      WorkoutController.instance.stopWorkout();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}