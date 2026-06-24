import 'package:flutter/material.dart';

class PillBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final EdgeInsetsGeometry padding;

  const PillBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor ?? theme.textTheme.headlineLarge?.color,
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}