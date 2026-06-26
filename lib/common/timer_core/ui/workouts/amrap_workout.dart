import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Assicurati di importare il tuo file delle stringhe localizzate, es:
// import '../../l10n/strings.dart';

class AmrapWorkoutWidget extends StatelessWidget {
  final dynamic timerState;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const AmrapWorkoutWidget({
    super.key,
    required this.timerState,
    required this.onIncrement,
    required this.onDecrement,
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

        // --- TOUCH TARGET CENTRALE (Bordato) ---
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onIncrement();
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: theme.colorScheme.primary.withAlpha(80),
                        width: 3
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "${timerState.currentRound ?? 0}",
                      style: TextStyle(
                        fontSize: 144,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // --- CONTROLLO (Bottone Rimuovi Bordato) ---
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              onDecrement();
            },
            icon: const Icon(Icons.undo, size: 16),
            // Sostituisci con la stringa da strings.dart
            label: const Text(
                "RIMUOVI ROUND",
                style: TextStyle(letterSpacing: 2, fontSize: 12)
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface.withAlpha(150),
              side: BorderSide(
                  color: theme.colorScheme.onSurface.withAlpha(50),
                  width: 1.5
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
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