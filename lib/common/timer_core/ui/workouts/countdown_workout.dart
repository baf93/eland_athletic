
import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:eland_athletic/common/strings.dart';
import 'package:flutter/material.dart';
import '../../models/timer_state.dart';

class CountdownWorkoutWidget extends StatelessWidget {
  final TimerState timerState;

  const CountdownWorkoutWidget({
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

    final double titleFont = (circleSize * 0.08).clamp(10.0, 22.0);
    final double timeFont = (circleSize * 0.22).clamp(40.0, 120.0);

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
              strokeWidth: circleSize * 0.06,
              strokeCap: StrokeCap.butt,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
              backgroundColor: theme.colorScheme.primary.withAlpha(30),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ElandStrings.of('time').toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: titleFont,
                  letterSpacing: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: r.compactGap),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _formatTime(timerState.remainingSeconds),
                  style: TextStyle(
                    fontSize: timeFont,
                    fontWeight: FontWeight.w900,
                    color: theme.textTheme.headlineLarge?.color,
                    fontFeatures: const [
                      FontFeature.tabularFigures(),
                    ],
                  ),
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
