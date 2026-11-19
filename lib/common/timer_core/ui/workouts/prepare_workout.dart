
import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:flutter/material.dart';
import '../../../strings.dart';
import '../../models/timer_state.dart';

class PrepareWorkoutWidget extends StatelessWidget {
  final TimerState timerState;

  const PrepareWorkoutWidget({
    super.key,
    required this.timerState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    if (!r.isLandscape) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: r.spacing(38),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${timerState.remainingSeconds}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: r.font(140, minScale: 0.78, maxScale: 1.08),
                fontWeight: FontWeight.w900,
                color: theme.textTheme.headlineLarge?.color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),

            SizedBox(height: r.spacing(20)),

            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                ElandStrings.of('get_ready').toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: r.font(32),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
            ),

            SizedBox(height: r.spacing(16)),

            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                ElandStrings.of('get_ready_desc').toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textTheme.bodyMedium!.color,
                  fontSize: r.font(16),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: r.spacing(24),
        vertical: r.spacing(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "${timerState.remainingSeconds}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: r.byUsableHeight(
                      0.28,
                      min: 80,
                      max: 160,
                    ),
                    fontWeight: FontWeight.w900,
                    color: theme.textTheme.headlineLarge?.color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: r.spacing(20)),

          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    ElandStrings.of('get_ready').toUpperCase(),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: r.byUsableHeight(
                        0.07,
                        min: 22,
                        max: 34,
                      ),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ),

                SizedBox(height: r.compactGap),

                Text(
                  ElandStrings.of('get_ready_desc').toUpperCase(),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium!.color,
                    fontSize: r.byUsableHeight(
                      0.04,
                      min: 13,
                      max: 18,
                    ),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}