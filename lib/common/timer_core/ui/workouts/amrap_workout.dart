import 'package:flutter/material.dart';

class AmrapWorkoutWidget extends StatelessWidget {
  final dynamic timerState;

  const AmrapWorkoutWidget({super.key, required this.timerState});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("AMRAP", style: TextStyle(color: Colors.white54, letterSpacing: 4)),
        const SizedBox(height: 20),
        Text(
          "${timerState.currentRound ?? 0}",
          style: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const Text("ROUNDS COMPLETED", style: TextStyle(color: Colors.white30, fontSize: 12, letterSpacing: 2)),
      ],
    );
  }
}