import 'package:flutter/material.dart';
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
    return InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      splashColor: iconColor?.withAlpha(50),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: elandColors.cardBorder!, width: 1),
        ),
        child: Icon(icon, color: iconColor, size: size * 0.43), // Proporzionale alla dimensione
      ),
    );
  }
}