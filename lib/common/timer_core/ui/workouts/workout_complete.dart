import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:eland_athletic/common/strings.dart';
import 'package:eland_athletic/common/timer_core/models/timer_block.dart';
import 'package:eland_athletic/common/workouts/models.dart';
import 'package:flutter/material.dart';

class WorkoutCompleteWidget extends StatelessWidget {
  /// Saved history entry, used to show the session results.
  final WorkoutLog? log;

  const WorkoutCompleteWidget({super.key, this.log});

  List<String> _resultLines() {
    final log = this.log;
    if (log == null) return const [];
    return [
      if (log.activeSeconds > 0)
        '${ElandStrings.of('total_time')}: ${TimerBlock.formatDuration(log.activeSeconds)}',
      if (log.amrapRounds != null)
        '${log.amrapRounds} ${ElandStrings.of('result_rounds')}',
      for (final r in log.forTimeResults)
        '${r.title}: ${TimerBlock.formatDuration(r.seconds)}${r.overCap ? ' (${ElandStrings.of('result_over_cap')})' : ''}',
    ];
  }

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

            for (final line in _resultLines()) ...[
              SizedBox(height: r.spacing(10)),
              Text(
                line.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: r.font(14, minScale: 0.9, maxScale: 1.2),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}