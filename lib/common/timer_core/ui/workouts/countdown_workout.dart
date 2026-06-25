import 'package:flutter/material.dart';

class CountdownWorkoutWidget extends StatelessWidget {
  final dynamic timerState;

  const CountdownWorkoutWidget({super.key, required this.timerState});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Cerchio di progresso per il countdown
            SizedBox(
              width: 280,
              height: 280,
              child: CircularProgressIndicator(
                value: timerState.intervalProgress,
                strokeWidth: 4, // Leggermente più sottile per un look elegante
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE69138)),
                backgroundColor: Colors.white10,
              ),
            ),

            // Layout centrale focalizzato sul tempo
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "TIME REMAINING",
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 12,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTime(timerState.remainingSeconds),
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(int s) {
    final absS = s.abs();
    return '${(absS ~/ 60).toString().padLeft(2, '0')}:${(absS % 60).toString().padLeft(2, '0')}';
  }
}