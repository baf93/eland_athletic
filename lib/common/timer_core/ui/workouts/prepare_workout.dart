import 'package:flutter/material.dart';
import '../../../strings.dart';
import '../../models/timer_state.dart';

class PrepareWorkoutWidget extends StatelessWidget {
  final TimerState timerState;

  const PrepareWorkoutWidget({super.key, required this.timerState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 38.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${timerState.remainingSeconds}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 140,
              fontWeight: FontWeight.w900,
              color: theme.textTheme.headlineLarge?.color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            ElandStrings.of('get_ready').toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ElandStrings.of('get_ready_desc').toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textTheme.bodyMedium!.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}