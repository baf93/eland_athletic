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
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
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

                  // Frecce "incastrate" usando Transform.translate
                  Row(
                    children: List.generate(totalSegments, (index) {
                      return Transform.translate(
                        offset: Offset(index == 0 ? 0 : -8.0 * index, 0),
                        child: Icon(
                          Icons.arrow_forward_ios_sharp,
                          size: 24,
                          color: index <= currentSegment
                              ? const Color(0xFFE69138)
                              : Colors.white10,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Container(height: 2, color: Colors.white10),
          ],
        ),
      ),
    );
  }
}