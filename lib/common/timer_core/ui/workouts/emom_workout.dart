import 'dart:ui';

import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:flutter/material.dart';
import '../../models/timer_state.dart';
import '../../../strings.dart';

class EmomWorkoutWidget extends StatelessWidget {
  final TimerState timerState;

  const EmomWorkoutWidget({
    super.key,
    required this.timerState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    final double maxCircleSize = r.isPhone ? 320 : (r.isTablet ? 520 : 560);

    final double circleSize = r.isLandscape
        ? r.byUsableHeight(
      0.84,
      min: 180,
      max: maxCircleSize,
    )
        : r.byWidth(
      0.74,
      min: 180,
      max: r.isPhone ? 320 : 460,
    );

    final double roundFont = (circleSize * 0.28).clamp(40.0, 130.0);
    final double subFont = (circleSize * 0.08).clamp(10.0, 34.0);
    final double timeFont = (circleSize * 0.10).clamp(14.0, 42.0);

    final double progress = 1.0 - timerState.intervalProgress;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: circleSize,
            height: circleSize,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: circleSize * 0.05,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
              backgroundColor: theme.colorScheme.onSurface.withAlpha(30),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ElandStrings.of('round').toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: subFont.clamp(10.0, 18.0),
                  letterSpacing: 4,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${timerState.currentRound}',
                    style: TextStyle(
                      fontSize: roundFont,
                      fontWeight: FontWeight.w900,
                      color: theme.textTheme.headlineLarge?.color,
                      fontFeatures: const [
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: r.spacing(4),
                      bottom: r.spacing(12),
                    ),
                    child: Text(
                      "/${timerState.totalRound}",
                      style: TextStyle(
                        fontSize: subFont.clamp(14.0, 32.0),
                        fontWeight: FontWeight.w600,
                        color:
                        theme.textTheme.bodyMedium?.color?.withAlpha(150),
                        fontFeatures: const [
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: r.compactGap),
              Text(
                _formatTime(timerState.remainingSeconds),
                style: TextStyle(
                  fontSize: timeFont,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyMedium?.color?.withAlpha(200),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
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
