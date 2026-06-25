import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ElandSegmentedProgressBar extends StatelessWidget {
  final int totalSegments;
  final int currentSegment;
  final VoidCallback onTap;

  const ElandSegmentedProgressBar({
    super.key,
    required this.totalSegments,
    required this.currentSegment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // GestureDetector avvolge il container per rendere l'intera area interattiva
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        color: Colors.transparent, // Assicura che l'intera area risponda al tocco
        child: Column(
          children: [
            // Linea superiore
            Container(height: 1, color: Colors.white10),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "PHASES",
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Frecce "incastrate" tramite Row e Transform.translate
                  // Questo evita padding negativi non consentiti dal framework
                  Row(
                    children: List.generate(totalSegments, (index) {
                      return Transform.translate(
                        offset: Offset(index == 0 ? 0 : -8.0 * index, 0),
                        child: Icon(
                          Icons.play_arrow,
                          size: 24,
                          color: index <= currentSegment
                              ? const Color(0xFFE69138) // Arancio Eland
                              : Colors.white10,         // Spento
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Linea inferiore
            Container(height: 1, color: Colors.white10),
          ],
        ),
      ),
    );
  }
}