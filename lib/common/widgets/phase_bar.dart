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

    // Get next phase
    final nextPhase = timerState.currentPhaseIndex < timerState.workoutPhaseSummary.length
        ? timerState.workoutPhaseSummary[timerState.currentPhaseIndex]
        : null;

    return GestureDetector(

      /// Manage Gesture and onTap
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

      /// UI
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 12, bottom: 12, left: 20, right: 20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // SX: Next with title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ElandStrings.of('next').toUpperCase(),
                    style: TextStyle(color: theme.textTheme.bodyMedium!.color, fontSize: 11, letterSpacing: 1),
                  ),
                  Text(
                    nextPhase != null
                        ? nextPhase.title
                        : ElandStrings.of('phase_complete').toUpperCase(),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              ),
            ),

            // Center: Notes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.notes_rounded,
                  size: 34,
                  color: (timerState.currentIntervalNotes?.isNotEmpty ?? false)
                      ? theme.colorScheme.primary
                      : theme.dividerColor.withAlpha(50),
                ),
              ),

            // DX: Phase number
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ElandStrings.of('phases').toUpperCase(),
                    style: TextStyle(color: theme.textTheme.bodyMedium!.color, fontSize: 11, letterSpacing: 1),
                  ),
                  Text(
                    '[ ${timerState.currentPhaseIndex}/${timerState.totalPhases} ]',
                    style: TextStyle(
                      color: theme.textTheme.headlineLarge!.color,
                      fontSize: 14,
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