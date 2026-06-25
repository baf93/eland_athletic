import 'package:flutter/material.dart';

class EmomWorkoutWidget extends StatelessWidget {
  final dynamic timerState;

  const EmomWorkoutWidget({super.key, required this.timerState});

  @override
  Widget build(BuildContext context) {
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
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE69138)),
                backgroundColor: Colors.white10,
              ),
            ),
            Column(
              children: [
                const Text("ROUND", style: TextStyle(color: Colors.white54, letterSpacing: 2)),
                Text(
                  "${timerState.currentRound ?? 1}", // Assumi che ci sia currentRound
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  "${(timerState.remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(timerState.remainingSeconds % 60).toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 24, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}