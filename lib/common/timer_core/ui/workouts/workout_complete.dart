import 'package:eland_athletic/common/strings.dart';
import 'package:flutter/material.dart';

class WorkoutCompleteWidget extends StatelessWidget {

  const WorkoutCompleteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.emoji_events_rounded,
            size: 100,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 40),

        Text(
          ElandStrings.of('workout_completed').toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.textTheme.headlineLarge?.color,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),

        Text(
          ElandStrings.of('great_job').toUpperCase(),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}