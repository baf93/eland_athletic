import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:flutter/material.dart';

class PrimaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final double height;
  final double? width;

  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.height = 60,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    final effectiveHeight = height == 60 ? r.primaryButtonHeight : height;

    // Phone landscape keeps the compact icon-only behavior.
    // Tablet / desktop landscape show both icon and label.
    final bool showLabel = label.isNotEmpty && (!r.isLandscape || !r.isPhone);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: r.isLandscape && r.isPhone ? 5 : r.spacing(40),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
          fixedSize: width != null
              ? Size(width!, effectiveHeight)
              : Size.fromHeight(effectiveHeight),
          padding: EdgeInsets.symmetric(
            horizontal: r.isLandscape && !r.isPhone ? r.spacing(18) : 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(r.radius(12)),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: r.isLandscape ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: r.icon(30),
              ),
              if (showLabel) SizedBox(width: r.spacing(12)),
            ],
            if (showLabel)
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: r.font(20),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
