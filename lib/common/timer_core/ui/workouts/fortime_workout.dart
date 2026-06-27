import 'package:eland_athletic/common/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../../models/timer_state.dart';
import '../../models/timercore_enums.dart';

class FortimeWorkoutWidget extends StatelessWidget {
  final TimerState timerState;

  const FortimeWorkoutWidget({super.key, required this.timerState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isPaused = timerState.status == TimerStatus.paused;
    final bool isOvertime = timerState.isOvertime;

    final double rawProgress = timerState.intervalProgress.clamp(0.0, 1.0);
    final double progress = isOvertime ? 0.0 : (1.0 - rawProgress);

    final Color borderColor = isPaused
        ? theme.dividerColor
        : (isOvertime ? Colors.redAccent : theme.colorScheme.primary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Column(
        children: [
          Expanded(
            child: Material(
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
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 3),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isPaused ? ElandStrings.of('paused').toUpperCase() : (isOvertime ? ElandStrings.of('overtime').toUpperCase() : ElandStrings.of('timer_fortime').toUpperCase()),
                        style: TextStyle(
                          color: borderColor,
                          letterSpacing: 4,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isOvertime ? ElandStrings.of('fortime_motivation_overtime').toUpperCase() : ElandStrings.of('fortime_motivation').toUpperCase(),
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium!.color,
                          fontSize: 16,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic
                        ),
                      ),
                      const Spacer(flex: 2),

                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isOvertime
                              ? "+${_formatTime(timerState.remainingSeconds)}"
                              : _formatTime(timerState.remainingSeconds),
                          style: TextStyle(
                            fontSize: 140,
                            fontWeight: FontWeight.w900,
                            color: theme.textTheme.headlineLarge!.color,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),

                      if (isOvertime)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            children: [
                              Text(
                                ElandStrings.of('total_time').toUpperCase(),
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium!.color,
                                  fontSize: 14,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatTime(timerState.elapsedSeconds),
                                style: TextStyle(
                                  color: theme.textTheme.headlineLarge!.color,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ),

                      const Spacer(flex: 3),

                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: ClipRRect(
                          borderRadius: BorderRadius.zero,
                          child: SizedBox(
                            height: 18,
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: borderColor.withAlpha(60),
                              valueColor: AlwaysStoppedAnimation<Color>(borderColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              isPaused ? ElandStrings.of('tap_to_close_phase').toUpperCase() : ElandStrings.of('tap_when_done').toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.dividerColor,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
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