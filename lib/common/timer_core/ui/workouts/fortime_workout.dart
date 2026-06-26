import 'package:flutter/material.dart';
import '../../models/timer_state.dart';

//TODO: bisogna modificare il backend per gestire il time cap

class FortimeWorkoutWidget extends StatelessWidget {
  final TimerState timerState;

  const FortimeWorkoutWidget({super.key, required this.timerState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Assumiamo che timerState.progress indichi il completamento rispetto al time cap
    final double progress = (timerState.intervalProgress ?? 0.0).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "FOR TIME",
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 16,
              letterSpacing: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 32),

          Text(
            _formatTime(timerState.remainingSeconds),
            style: TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.w900,
              color: theme.textTheme.headlineLarge?.color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),

          const SizedBox(height: 32),

          // Barra di progresso lineare per il Time Cap
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.onSurface.withAlpha(30),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int s) {
    final absS = s.abs();
    return '${(absS ~/ 60).toString().padLeft(2, '0')}:${(absS % 60).toString().padLeft(2, '0')}';
  }
}