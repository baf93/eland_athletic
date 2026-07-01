import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:flutter/material.dart';
import '../theme.dart';

class ElandCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback? onTap;

  const ElandCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elandColors = theme.extension<ElandCustomColors>()!;
    final r = ElandResponsive(context);

    final borderRadius = r.radius(16);
    final horizontalPadding = r.adaptive(18, 22, 24);
    final verticalPadding = r.adaptive(14, 16, 18);

    Widget cardContent = Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: elandColors.cardBorder!,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: r.font(18, maxScale: 1.12),
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),

          if (subtitle != null) ...[
            SizedBox(height: r.compactGap),
            Text(
              subtitle!.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: r.font(11, maxScale: 1.12),
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodySmall?.color,
                letterSpacing: 1.1,
              ),
            ),
          ],

          SizedBox(height: r.sectionGap),

          child,
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}