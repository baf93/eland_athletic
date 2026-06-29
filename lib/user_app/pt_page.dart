import 'package:flutter/material.dart';
import 'package:eland_athletic/common/strings.dart';

class PtPage extends StatelessWidget {
  const PtPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction_rounded,
                size: 80,
                color: colorScheme.primary.withAlpha(200),
              ),
              const SizedBox(height: 40),

              Text(
                "STAY TUNED".toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: theme.textTheme.headlineLarge!.color,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                ElandStrings.of('workout_wip').toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 1,
                  color: theme.textTheme.bodyMedium!.color?.withAlpha(150),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}