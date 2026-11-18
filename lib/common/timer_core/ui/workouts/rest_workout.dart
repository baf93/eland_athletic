
import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:flutter/material.dart';
import '../../../strings.dart';
import '../../models/timer_state.dart';

class RestWorkoutWidget extends StatelessWidget {
  final TimerState timerState;

  const RestWorkoutWidget({
    super.key,
    required this.timerState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final primaryColor = theme.colorScheme.primary;

    final titleSize = r.isLandscape
        ? r.byUsableHeight(0.08, min: 24, max: 38)
        : r.font(32);

    final timerSize = r.isLandscape
        ? r.byUsableHeight(0.22, min: 80, max: 135)
        : r.font(120, minScale: 0.78, maxScale: 1.08);

    final subtitleSize = r.isLandscape
        ? r.byUsableHeight(0.045, min: 14, max: 20)
        : r.font(14);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: r.pageHorizontalPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              ElandStrings.of('timer_rest').toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor,
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                letterSpacing: r.isLandscape ? 8 : 12,
              ),
            ),
          ),

          SizedBox(
            height: r.isLandscape
                ? r.byUsableHeight(0.03, min: 10, max: 24)
                : r.spacing(24),
          ),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatTime(timerState.remainingSeconds),
              style: TextStyle(
                fontSize: timerSize,
                fontWeight: FontWeight.w900,
                color: theme.textTheme.headlineLarge?.color,
                fontFeatures: const [
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
          ),

          SizedBox(
            height: r.isLandscape
                ? r.byUsableHeight(0.04, min: 12, max: 32)
                : r.spacing(32),
          ),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              ElandStrings.of('breathe').toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textTheme.bodyMedium!.color,
                fontSize: subtitleSize,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                letterSpacing: r.isLandscape ? 1.5 : 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int s) {
    final absS = s.abs();

    return '${(absS ~/ 60).toString().padLeft(2, '0')}:'
        '${(absS % 60).toString().padLeft(2, '0')}';
  }
}