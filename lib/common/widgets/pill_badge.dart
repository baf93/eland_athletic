import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:flutter/material.dart';

class PillBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const PillBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    final adaptivePadding =
        padding ??
            EdgeInsets.symmetric(
              horizontal: r.spacing(12),
              vertical: r.spacing(6),
            );

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: adaptivePadding,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(r.radius(50)),
          border: Border.all(
            color: theme.dividerColor,
          ),
        ),
        child: Text(
          text.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor ?? theme.textTheme.headlineLarge?.color,
            fontSize: fontSize ?? r.font(12),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}