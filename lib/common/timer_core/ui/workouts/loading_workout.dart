import 'package:eland_athletic/common/strings.dart';
import 'package:flutter/material.dart';

class WorkoutLoadingPage extends StatelessWidget {
  const WorkoutLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bolt_rounded,
                size: 100,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 25),

              Text(
                ElandStrings.of('loading_workout').toUpperCase(),
                style: TextStyle(
                  color: theme.textTheme.headlineLarge!.color,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 60),

              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}