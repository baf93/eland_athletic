import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "../theme.dart";

class TimerRowItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const TimerRowItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elandColors = theme.extension<ElandCustomColors>()!;
    final r = ElandResponsive(context);

    final borderRadius = r.radius(16);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: r.isSmallPhone ? 16 : r.spacing(20),
            vertical: r.isSmallPhone ? 14 : r.spacing(18),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: elandColors.cardBorder!,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: r.icon(24),
                color: theme.colorScheme.primary,
              ),

              SizedBox(width: r.spacing(20)),

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: r.font(15),
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: r.icon(16),
                color: theme.textTheme.bodyMedium?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}