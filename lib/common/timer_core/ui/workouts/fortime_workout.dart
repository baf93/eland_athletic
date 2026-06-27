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
    final double progress = isOvertime ? 0.0 : (timerState.intervalProgress ?? 0.0).clamp(0.0, 1.0);

    final Color borderColor = isPaused
        ? theme.colorScheme.onSurface.withOpacity(0.2)
        : (isOvertime ? Colors.redAccent : theme.colorScheme.primary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor, width: 3),
                  ),
                  child: Column(
                    children: [
                      // Header e Motivazione nello stesso blocco
                      Text(
                        isPaused ? "PAUSA" : (isOvertime ? "OVERTIME" : "FOR TIME"),
                        style: TextStyle(
                          color: borderColor,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isOvertime ? "NON MOLLARE ORA" : "SPINGI AL MASSIMO",
                        style: TextStyle(
                          color: borderColor.withOpacity(0.6),
                          fontSize: 10,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),

                      // Timer Centrale
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isOvertime ? "+${_formatTime(timerState.remainingSeconds)}" : _formatTime(timerState.remainingSeconds),
                          style: const TextStyle(
                            fontSize: 140,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),

                      if (isOvertime)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text("TOT: ${_formatTime(timerState.elapsedSeconds)}",
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                        ),

                      const Spacer(),

                      // Barra
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: borderColor.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(borderColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Istruzioni in basso (fuori dal container)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              isPaused ? "TOCCA PER CONCLUDERE LA FASE" : "TOCCA PER PAUSARE E FINIRE",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
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