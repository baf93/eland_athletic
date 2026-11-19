
import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:eland_athletic/common/strings.dart';
import 'package:flutter/material.dart';

import '../../models/timer_state.dart';
import '../../models/timercore_enums.dart';

class TabataWorkoutWidget extends StatelessWidget {
  final TimerState timerState;

  const TabataWorkoutWidget({
    super.key,
    required this.timerState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    final phase = timerState.intervalType;
    final isWork = phase == IntervalType.work;
    final isCooldown = phase == IntervalType.cooldown;

    final workColor = theme.colorScheme.primary;
    final restColor = theme.colorScheme.tertiary;
    final cooldownColor = theme.textTheme.bodyMedium!.color!;

    final currentColor = isWork
        ? workColor
        : (isCooldown ? cooldownColor : restColor);

    return r.isLandscape
        ? _buildLandscape(
      context,
      theme,
      r,
      currentColor,
      isWork,
      isCooldown,
    )
        : _buildPortrait(
      context,
      theme,
      r,
      currentColor,
      isWork,
      isCooldown,
    );
  }

  Widget _buildPortrait(
      BuildContext context,
      ThemeData theme,
      ElandResponsive r,
      Color currentColor,
      bool isWork,
      bool isCooldown,
      ) {
    final barHeight = isCooldown ? 2.0 : r.spacing(12);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: r.spacing(24),
        vertical: r.spacing(32),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile(
                ElandStrings.of('round').toUpperCase(),
                "${timerState.currentRound}/${timerState.totalRound}",
                theme,
                r,
              ),
              _infoTile(
                ElandStrings.of('set').toUpperCase(),
                "${timerState.currentSet}/${timerState.totalSet}",
                theme,
                r,
                alignRight: true,
              ),
            ],
          ),

          const Spacer(),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isCooldown
                  ? ElandStrings.of('cooldown_time').toUpperCase()
                  : (isWork
                  ? ElandStrings.of('work_time').toUpperCase()
                  : ElandStrings.of('rest_time').toUpperCase()),
              style: TextStyle(
                color: currentColor,
                fontSize: r.font(32),
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ),

          SizedBox(height: r.spacing(30)),

          FittedBox(
            child: Text(
              _formatTime(timerState.remainingSeconds),
              style: TextStyle(
                color: theme.textTheme.headlineLarge!.color,
                fontSize: r.font(110, minScale: 0.78, maxScale: 1.08),
                fontWeight: FontWeight.w900,
                height: 1,
                fontFeatures: const [
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
          ),

          SizedBox(height: r.spacing(30)),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: barHeight,
            width: double.infinity,
            child: LinearProgressIndicator(
              value: 1.0 - timerState.intervalProgress,
              backgroundColor: theme.colorScheme.onSurface.withAlpha(50),
              valueColor: AlwaysStoppedAnimation(currentColor),
            ),
          ),

          SizedBox(height: r.spacing(30)),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _getMotivation(timerState.intervalType).toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textTheme.bodyMedium!.color,
                fontStyle: FontStyle.italic,
                fontSize: r.font(16),
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildLandscape(
      BuildContext context,
      ThemeData theme,
      ElandResponsive r,
      Color currentColor,
      bool isWork,
      bool isCooldown,
      ) {
    final sideWidth = r.byWidth(
      0.16,
      min: 100,
      max: 140,
    );

    final timerFont = r.byUsableHeight(
      0.34,
      min: 80,
      max: 150,
    );

    final titleFont = r.byUsableHeight(
      0.075,
      min: 24,
      max: 38,
    );

    final motivationFont = r.byUsableHeight(
      0.03,
      min: 12,
      max: 18,
    );

    final infoLabelFont = r.byUsableHeight(
      0.022,
      min: 10,
      max: 14,
    );

    final infoValueFont = r.byUsableHeight(
      0.065,
      min: 24,
      max: 36,
    );

    final barHeight = isCooldown ? 2.0 : r.spacing(8);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: r.spacing(24),
        vertical: r.spacing(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: sideWidth,
            child: Column(
              children: [
                _infoTile(
                  ElandStrings.of('round').toUpperCase(),
                  "${timerState.currentRound}/${timerState.totalRound}",
                  theme,
                  r,
                  labelSize: infoLabelFont,
                  valueSize: infoValueFont,
                ),

                const Spacer(),

                _infoTile(
                  ElandStrings.of('set').toUpperCase(),
                  "${timerState.currentSet}/${timerState.totalSet}",
                  theme,
                  r,
                  labelSize: infoLabelFont,
                  valueSize: infoValueFont,
                ),
              ],
            ),
          ),

          SizedBox(width: r.spacing(24)),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isCooldown
                        ? ElandStrings.of('cooldown_time').toUpperCase()
                        : (isWork
                        ? ElandStrings.of('work_time').toUpperCase()
                        : ElandStrings.of('rest_time').toUpperCase()),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: currentColor,
                      fontSize: titleFont,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ),

                SizedBox(height: r.spacing(20)),

                FittedBox(
                  child: Text(
                    _formatTime(timerState.remainingSeconds),
                    style: TextStyle(
                      color: theme.textTheme.headlineLarge!.color,
                      fontSize: timerFont,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      fontFeatures: const [
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: r.spacing(24)),

                SizedBox(
                  width: r.byWidth(
                    0.55,
                    min: 220,
                    max: 620,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: barHeight,
                    child: LinearProgressIndicator(
                      value: 1.0 - timerState.intervalProgress,
                      backgroundColor:
                      theme.colorScheme.onSurface.withAlpha(50),
                      valueColor: AlwaysStoppedAnimation(currentColor),
                    ),
                  ),
                ),

                SizedBox(height: r.spacing(24)),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _getMotivation(timerState.intervalType).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium!.color,
                      fontStyle: FontStyle.italic,
                      fontSize: motivationFont,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
      String label,
      String value,
      ThemeData theme,
      ElandResponsive r, {
        bool alignRight = false,
        double? labelSize,
        double? valueSize,
      }) {
    final effectiveLabelSize = labelSize ?? r.font(12);
    final effectiveValueSize = valueSize ?? r.font(30);

    return Column(
      crossAxisAlignment:
      alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: effectiveLabelSize,
            fontWeight: FontWeight.w900,
            letterSpacing: effectiveLabelSize * 0.25,
            color: theme.textTheme.bodyMedium!.color,
          ),
        ),
        FittedBox(
          child: Text(
            value,
            style: TextStyle(
              fontSize: effectiveValueSize,
              fontWeight: FontWeight.w900,
              letterSpacing: effectiveValueSize * 0.1,
              color: theme.textTheme.headlineLarge!.color,
            ),
          ),
        ),
      ],
    );
  }

  String _getMotivation(IntervalType phase) {
    if (phase == IntervalType.work) {
      return ElandStrings.of('tabata_motivation_work');
    }

    if (phase == IntervalType.rest) {
      return ElandStrings.of('tabata_motivation_rest');
    }

    return ElandStrings.of('tabata_motivation_cooldown');
  }

  String _formatTime(int s) {
    final absS = s.abs();

    return '${(absS ~/ 60).toString().padLeft(2, '0')}:${(absS % 60).toString().padLeft(2, '0')}';
  }
}