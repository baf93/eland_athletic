import 'package:flutter/material.dart';
import '../../../strings.dart';
import '../../models/timer_state.dart';

class RestWorkoutWidget extends StatelessWidget {
  final TimerState timerState;

  const RestWorkoutWidget({super.key, required this.timerState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color primaryColor = theme.colorScheme.primary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Text(
          ElandStrings.of('timer_rest').toUpperCase(),
          style: TextStyle(
            color: primaryColor,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 12,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          _formatTime(timerState.remainingSeconds),
          style: TextStyle(
            fontSize: 120,
            fontWeight: FontWeight.w900,
            color: theme.textTheme.headlineLarge?.color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),

        const SizedBox(height: 32),

        Text(
          ElandStrings.of('breathe').toUpperCase(),
          style: TextStyle(
            color: theme.textTheme.bodyMedium!.color,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  String _formatTime(int s) {
    final absS = s.abs();
    return '${(absS ~/ 60).toString().padLeft(2, '0')}:${(absS % 60).toString().padLeft(2, '0')}';
  }
}