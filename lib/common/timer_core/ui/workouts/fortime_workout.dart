
import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:eland_athletic/common/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../../models/timer_state.dart';
import '../../models/timercore_enums.dart';

class FortimeWorkoutWidget extends StatelessWidget {
  final TimerState timerState;

  const FortimeWorkoutWidget({
    super.key,
    required this.timerState,
  });

  @override
  Widget build(BuildContext context) {
    final r = ElandResponsive(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: r.spacing(14),
        horizontal: r.spacing(12),
      ),
      child: r.isLandscape
          ? _buildLandscape(context, r)
          : _buildPortrait(context, r),
    );
  }

  Widget _buildPortrait(BuildContext context, ElandResponsive r) {
    final theme = Theme.of(context);

    final bool isPaused = timerState.status == TimerStatus.paused;
    final bool isOvertime = timerState.isOvertime;

    final double progress =
    isOvertime ? 0.0 : (1.0 - timerState.intervalProgress.clamp(0.0, 1.0));

    final Color borderColor = isPaused
        ? theme.dividerColor
        : (isOvertime ? Colors.redAccent : theme.colorScheme.primary);

    return Column(
      children: [
        Expanded(
          child: _buildTouchArea(
            context,
            theme,
            r,
            borderColor,
            progress,
          ),
        ),
        SizedBox(height: r.spacing(12)),
        Text(
          isPaused
              ? ElandStrings.of('tap_to_close_phase').toUpperCase()
              : ElandStrings.of('tap_when_done').toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.dividerColor,
            fontSize: r.font(11),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLandscape(BuildContext context, ElandResponsive r) {
    final theme = Theme.of(context);

    final bool isPaused = timerState.status == TimerStatus.paused;
    final bool isOvertime = timerState.isOvertime;

    final double progress =
    isOvertime ? 0.0 : (1.0 - timerState.intervalProgress.clamp(0.0, 1.0));

    final Color borderColor = isPaused
        ? theme.dividerColor
        : (isOvertime ? Colors.redAccent : theme.colorScheme.primary);

    return Row(
      children: [
        Expanded(
          child: _buildTouchArea(
            context,
            theme,
            r,
            borderColor,
            progress,
          ),
        ),
      ],
    );
  }

  Widget _buildTouchArea(
      BuildContext context,
      ThemeData theme,
      ElandResponsive r,
      Color borderColor,
      double progress,
      ) {
    final bool isPaused = timerState.status == TimerStatus.paused;
    final bool isOvertime = timerState.isOvertime;

    final double titleSize = r.isLandscape
        ? r.byUsableHeight(0.065, min: 20, max: 32)
        : r.font(22);

    final double motivationSize = r.isLandscape
        ? r.byUsableHeight(0.035, min: 12, max: 18)
        : r.font(14);

    final double timerSize = r.isLandscape
        ? r.byUsableHeight(0.31, min: 82, max: 155)
        : r.font(150, minScale: 0.78, maxScale: 1.08);

    final double totalLabelSize = r.isLandscape
        ? r.byUsableHeight(0.026, min: 9, max: 13)
        : r.font(14);

    final double totalValueSize = r.isLandscape
        ? r.byUsableHeight(0.038, min: 13, max: 20)
        : r.font(18);

    final double progressHeight = r.isLandscape
        ? r.byUsableHeight(0.025, min: 8, max: 14)
        : r.spacing(14);

    final double padding = r.isLandscape ? r.spacing(12) : r.spacing(24);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();

          if (timerState.status == TimerStatus.paused) {
            FlutterBackgroundService().invoke('skipPhase');
          } else {
            FlutterBackgroundService().invoke('pause');
          }
        },
        borderRadius: BorderRadius.circular(r.radius(16)),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r.radius(16)),
            border: Border.all(
              color: borderColor,
              width: 3,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isPaused
                          ? ElandStrings.of('paused').toUpperCase()
                          : (isOvertime
                          ? ElandStrings.of('overtime').toUpperCase()
                          : ElandStrings.of('timer_fortime')
                          .toUpperCase()),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: borderColor,
                        letterSpacing: 4,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(height: r.isLandscape ? 4 : r.compactGap),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isOvertime
                          ? ElandStrings.of('fortime_motivation_overtime')
                          .toUpperCase()
                          : ElandStrings.of('fortime_motivation')
                          .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium!.color,
                        fontSize: motivationSize,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),

              Flexible(
                child: isOvertime && r.isLandscape
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 3,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "+${_formatTime(timerState.remainingSeconds)}",
                          style: TextStyle(
                            fontSize: timerSize,
                            fontWeight: FontWeight.w900,
                            color: theme.textTheme.headlineLarge!.color,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: r.spacing(20)),

                    Flexible(
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              ElandStrings.of('total_time')
                                  .toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium!.color,
                                fontSize: totalLabelSize,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: r.spacing(2)),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _formatTime(timerState.elapsedSeconds),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                theme.textTheme.headlineLarge!.color,
                                fontSize: totalValueSize,
                                fontWeight: FontWeight.w600,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isOvertime
                            ? "+${_formatTime(timerState.remainingSeconds)}"
                            : _formatTime(timerState.remainingSeconds),
                        style: TextStyle(
                          fontSize: timerSize,
                          fontWeight: FontWeight.w900,
                          color: theme.textTheme.headlineLarge!.color,
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ),

                    if (isOvertime) ...[
                      SizedBox(height: r.compactGap),
                      Text(
                        ElandStrings.of('total_time').toUpperCase(),
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium!.color,
                          fontSize: totalLabelSize,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(timerState.elapsedSeconds),
                        style: TextStyle(
                          color: theme.textTheme.headlineLarge!.color,
                          fontSize: totalValueSize,
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(
                height: progressHeight,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: borderColor.withAlpha(60),
                  valueColor: AlwaysStoppedAnimation(borderColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int s) {
    final absS = s.abs();

    return '${(absS ~/ 60).toString().padLeft(2, '0')}:${(absS % 60).toString().padLeft(2, '0')}';
  }
}