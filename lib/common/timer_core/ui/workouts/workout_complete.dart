import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:eland_athletic/common/strings.dart';
import 'package:flutter/material.dart';

class WorkoutCompleteWidget extends StatelessWidget {
  const WorkoutCompleteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: r.pageHorizontalPadding,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(
                r.spacing(
                  24,
                  minScale: 0.8,
                  maxScale: 1.3,
                ),
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                size: r.icon(
                  100,
                  minScale: 0.8,
                  maxScale: 1.4,
                ),
                color: theme.colorScheme.primary,
              ),
            ),

            SizedBox(height: r.spacing(40)),

            FittedBox(
              child: Text(
                ElandStrings.of('workout_completed').toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textTheme.headlineLarge?.color,
                  fontSize: r.font(
                    32,
                    minScale: 0.9,
                    maxScale: 1.25,
                  ),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  height: 1.1,
                ),
              ),
            ),

            SizedBox(height: r.compactGap),

            FittedBox(
              child: Text(
                ElandStrings.of('great_job').toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: r.font(
                    16,
                    minScale: 0.9,
                    maxScale: 1.2,
                  ),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}