import 'package:flutter/material.dart';

import '../../common/eland_responsive.dart';
import '../../common/theme.dart';
import '../../common/timer_core/models/timer_block.dart';
import '../../common/timer_core/models/timercore_enums.dart';

/// Thin bar with one segment per phase, proportional to its duration:
/// orange for work, grey for rest.
class PhaseStrip extends StatelessWidget {
  final List<TimerBlock> blocks;
  final double height;

  const PhaseStrip({super.key, required this.blocks, this.height = 4});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rest =
        theme.extension<ElandCustomColors>()?.cardBorder ?? theme.dividerColor;
    final visible = blocks.where((b) => b.totalSeconds > 0).toList();
    if (visible.isEmpty) return SizedBox(height: height);

    return SizedBox(
      height: height,
      child: Row(
        // Empty DecoratedBoxes take no height unless stretched.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Expanded(
              flex: visible[i].totalSeconds,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: visible[i].type == TimerType.rest
                      ? rest
                      : theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One phase as a compact line: leading (number or drag handle), name,
/// settings, duration. Separated from the next one by a hairline.
class PhaseLine extends StatelessWidget {
  final TimerBlock block;
  final Widget leading;
  final VoidCallback? onTap;

  const PhaseLine({
    super.key,
    required this.block,
    required this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final muted = theme.textTheme.bodyMedium?.color;
    final border =
        theme.extension<ElandCustomColors>()?.cardBorder ?? theme.dividerColor;
    final duration = TimerBlock.formatDuration(block.totalSeconds);
    // Timers whose only setting is the duration already show it on the right.
    final settings = block.settingsLabel == duration ? '' : block.settingsLabel;
    final notes = block.notes?.trim() ?? '';

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: r.spacing(14)),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: border, width: 0.8)),
          ),
          child: Row(
            children: [
              SizedBox(width: r.spacing(28), child: leading),
              SizedBox(width: r.spacing(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      block.displayTitle.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: r.font(14),
                        letterSpacing: 1.1,
                        color: block.isValid ? null : Colors.redAccent,
                      ),
                    ),
                    if (notes.isNotEmpty)
                      Text(
                        notes,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: r.font(12),
                          fontStyle: FontStyle.italic,
                          color: muted,
                        ),
                      ),
                  ],
                ),
              ),
              if (settings.isNotEmpty) ...[
                Text(
                  settings,
                  style: TextStyle(fontSize: r.font(13), color: muted),
                ),
                SizedBox(width: r.spacing(14)),
              ],
              SizedBox(
                width: r.spacing(52),
                child: Text(
                  duration,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: r.font(14),
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
