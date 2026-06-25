import 'package:flutter/material.dart';

class FortimeWorkoutWidget extends StatelessWidget {
  final dynamic timerState;

  const FortimeWorkoutWidget({super.key, required this.timerState});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("FOR TIME", style: TextStyle(color: Colors.white54, letterSpacing: 4)),
        const SizedBox(height: 20),
        Text(
          "${(timerState.remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(timerState.remainingSeconds % 60).toString().padLeft(2, '0')}",
          style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'monospace'),
        ),
      ],
    );
  }
}