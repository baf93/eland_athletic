import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class ElandActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? borderColor;
  final double size;

  const ElandActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor,
    this.borderColor,
    this.size = 65.0,
  });

  @override
  Widget build(BuildContext context) {
    final elandColors = Theme.of(context).extension<ElandCustomColors>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          HapticFeedback.mediumImpact();
          onPressed();
        },
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: borderColor ?? elandColors.cardBorder!,
                width: 2
            ),
          ),
          child: Center(
            child: Icon(
                icon,
                color: iconColor,
                size: size * 0.43
            ),
          ),
        ),
      ),
    );
  }
}