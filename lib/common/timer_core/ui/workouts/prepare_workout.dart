import 'package:flutter/material.dart';

class PrepareWorkoutWidget extends StatelessWidget {
  final dynamic timerState;

  const PrepareWorkoutWidget({super.key, required this.timerState});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
            "GET READY",
            style: TextStyle(
                color: Color(0xFFF1C232), // Giallo ambrato (visibile e di avviso)
                fontSize: 16,
                letterSpacing: 6,
                fontWeight: FontWeight.bold
            )
        ),
        const SizedBox(height: 25),
        Text(
          "${timerState.remainingSeconds}", // Spesso il prepare è breve, mostriamo solo i secondi
          style: const TextStyle(
            fontSize: 96,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
            "PREPARING...",
            style: TextStyle(color: Colors.white30, fontSize: 12, letterSpacing: 2)
        ),
      ],
    );
  }
}