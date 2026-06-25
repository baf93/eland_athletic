import 'package:flutter/material.dart';
import '../../models/timer_state.dart';

class TabataWorkoutWidget extends StatelessWidget {
  final TimerState timerState;

  const TabataWorkoutWidget({super.key, required this.timerState});

  @override
  Widget build(BuildContext context) {
    // Logica colore: Arancio per lavoro, Verde per riposo
    final isRest = timerState.currentIntervalTitle.toLowerCase().contains('rest');
    final color = isRest ? const Color(0xFF4CAF50) : const Color(0xFFE69138);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 260,
              height: 260,
              child: CircularProgressIndicator(
                value: timerState.intervalProgress,
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                backgroundColor: Colors.white10,
              ),
            ),
            Column(
              children: [
                Text(timerState.currentIntervalTitle.toUpperCase(),
                    style: const TextStyle(color: Colors.white54, letterSpacing: 2)),
                Text(
                  "${(timerState.remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(timerState.remainingSeconds % 60).toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}