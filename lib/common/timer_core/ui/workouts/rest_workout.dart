import 'package:flutter/material.dart';

class RestWorkoutWidget extends StatelessWidget {
  final dynamic timerState;

  const RestWorkoutWidget({super.key, required this.timerState});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("REST", style: TextStyle(color: Color(0xFF4CAF50), fontSize: 18, letterSpacing: 6, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Text(
          "${(timerState.remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(timerState.remainingSeconds % 60).toString().padLeft(2, '0')}",
          style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}