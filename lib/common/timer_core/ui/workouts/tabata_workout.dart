import 'package:eland_athletic/common/strings.dart';
import 'package:flutter/material.dart';
import '../../models/timer_state.dart';
import '../../models/timercore_enums.dart';

class TabataWorkoutWidget extends StatelessWidget {
  final TimerState timerState;

  const TabataWorkoutWidget({super.key, required this.timerState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phase = timerState.intervalType;
    final isWork = phase == IntervalType.work;
    final isCooldown = phase == IntervalType.cooldown;

    final Color workColor = theme.colorScheme.primary;
    final Color restColor = theme.colorScheme.tertiary;
    final Color cooldownColor = theme.textTheme.bodyMedium!.color!;

    final Color currentColor = isWork
        ? workColor
        : (isCooldown ? cooldownColor : restColor);

    final double barHeight = isCooldown ? 2.0 : 12.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile(ElandStrings.of('round').toUpperCase(), "${timerState.currentRound}/${timerState.totalRound}", theme),
              _infoTile(ElandStrings.of('set').toUpperCase(), "${timerState.currentSet}/${timerState.totalSet}", theme, alignRight: true),
            ],
          ),
          const Spacer(flex: 1),
          Text(
            isCooldown ? ElandStrings.of('cooldown_time').toUpperCase() : (isWork ? ElandStrings.of('work_time').toUpperCase() : ElandStrings.of('rest_time').toUpperCase()),
            style: TextStyle(
                color: currentColor,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 3
            ),
          ),

          const SizedBox(height: 30),

          Text(
            _formatTime(timerState.remainingSeconds),
            style: TextStyle(
                color: theme.textTheme.headlineLarge!.color,
                fontSize: 110,
                fontWeight: FontWeight.w900,
                height: 1,
                fontFeatures: [FontFeature.tabularFigures()]
            ),
          ),

          const SizedBox(height: 30),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: barHeight,
            width: double.infinity,
            child: LinearProgressIndicator(
              value: 1.0 - timerState.intervalProgress,
              backgroundColor: theme.colorScheme.onSurface.withAlpha(50),
              valueColor: AlwaysStoppedAnimation<Color>(currentColor),
            ),
          ),

          const SizedBox(height: 30),

          Center(
            child: Text(
              _getMotivation(phase).toUpperCase(),
              style: TextStyle(
                  color: theme.textTheme.bodyMedium!.color,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4
              ),
            ),
          ),

          const Spacer(flex: 2),

        ],
      ),
    );
  }

  Widget _infoTile(String label, String value, ThemeData theme, {bool alignRight = false}) => Column(
    crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 3, color: theme.textTheme.bodyMedium!.color)
      ),
      Text(
          value,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 3, color: theme.textTheme.headlineLarge!.color)
      ),
    ],
  );

  String _getMotivation(IntervalType phase) {
    if (phase == IntervalType.work) return ElandStrings.of('tabata_motivation_work').toUpperCase();
    if (phase == IntervalType.rest) return ElandStrings.of('tabata_motivation_rest').toUpperCase();
    return ElandStrings.of('tabata_motivation_cooldown').toUpperCase();
  }

  String _formatTime(int s) {
    final absS = s.abs();
    return '${(absS ~/ 60).toString().padLeft(2, '0')}:${(absS % 60).toString().padLeft(2, '0')}';
  }
}