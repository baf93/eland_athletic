import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../strings.dart';
import '../../models/timer_state.dart';

class AmrapWorkoutWidget extends StatelessWidget {
  final TimerState timerState;
  final ValueNotifier<int> roundNotifier;

  const AmrapWorkoutWidget({
    super.key,
    required this.timerState,
    required this.roundNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 10),

        Text(
          _formatTime(timerState.remainingSeconds),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: theme.textTheme.headlineLarge?.color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),

        // --- TOUCH TARGET
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  roundNotifier.value++;
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: ValueListenableBuilder<int>(
                      valueListenable: roundNotifier,
                      builder: (context, value, child) {
                        return Text(
                          "$value",
                          style: TextStyle(
                            fontSize: 144,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // --- Remove ---
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              if (roundNotifier.value > 0) {
                roundNotifier.value--;
              }
            },
            icon: const Icon(Icons.undo, size: 16),
            label: Text(
              ElandStrings.of('remove_round').toUpperCase(),
              style: TextStyle(letterSpacing: 2, fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: BorderSide(
                color: theme.dividerColor,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(int s) {
    final absS = s.abs();
    return '${(absS ~/ 60).toString().padLeft(2, '0')}:${(absS % 60).toString().padLeft(2, '0')}';
  }
}