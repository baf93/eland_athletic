import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../timer_core/models/timer_state.dart';
import 'package:eland_athletic/common/strings.dart';

class PhaseBar extends StatelessWidget {
  final TimerState timerState;
  final VoidCallback onTap;

  const PhaseBar({
    super.key,
    required this.timerState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    final nextPhase =
    timerState.currentPhaseIndex < timerState.workoutPhaseSummary.length
        ? timerState.workoutPhaseSummary[timerState.currentPhaseIndex]
        : null;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < -5) {
          HapticFeedback.lightImpact();
          onTap();
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: r.spacing(18),
          vertical: r.spacing(12),
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: theme.dividerColor),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ElandStrings.of('next').toUpperCase(),
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium!.color,
                      fontSize: r.font(11),
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: r.spacing(2)),
                  Text(
                    nextPhase != null
                        ? nextPhase.title
                        : ElandStrings.of('phase_complete').toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: r.font(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: r.spacing(16),
              ),
              child: Icon(
                Icons.notes_rounded,
                size: r.icon(34),
                color: (timerState.currentIntervalNotes?.isNotEmpty ?? false)
                    ? theme.colorScheme.primary
                    : theme.dividerColor.withAlpha(70),
              ),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ElandStrings.of('phases').toUpperCase(),
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium!.color,
                      fontSize: r.font(11),
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: r.spacing(2)),
                  Text(
                    '[ ${timerState.currentPhaseIndex}/${timerState.totalPhases} ]',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: theme.textTheme.headlineLarge!.color,
                      fontSize: r.font(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}