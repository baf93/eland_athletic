import 'package:eland_athletic/common/eland_responsive.dart';
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
    this.size = 65,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elandColors = theme.extension<ElandCustomColors>()!;
    final r = ElandResponsive(context);

    final effectiveSize =
    size == 65
        ? r.iconButtonSize
        : size;

    final iconSize = effectiveSize * 0.43;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          HapticFeedback.mediumImpact();
          onPressed();
        },
        child: Container(
          width: effectiveSize,
          height: effectiveSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor ?? elandColors.cardBorder!,
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? theme.textTheme.headlineLarge?.color,
            ),
          ),
        ),
      ),
    );
  }
}