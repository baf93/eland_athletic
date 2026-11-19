import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:flutter/material.dart';

BoxDecoration _sheetDecoration(ThemeData theme, ElandResponsive r) =>
    BoxDecoration(
      color: theme.scaffoldBackgroundColor,
      borderRadius: BorderRadius.vertical(top: Radius.circular(r.radius(24))),
      border: Border.all(color: theme.dividerColor),
    );

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: r.spacing(r.isLandscape ? 10 : 14)),
      width: r.byWidth(0.10, min: 32, max: 42),
      height: r.spacing(5, minScale: 0.8, maxScale: 1.2),
      decoration: BoxDecoration(
        color: theme.dividerColor,
        borderRadius: BorderRadius.circular(r.radius(6)),
      ),
    );
  }
}

/// Draggable sheet for long lists (phases during a workout).
class ElandBottomSheet extends StatelessWidget {
  final Widget Function(ScrollController scrollController) builder;
  final double? initialChildSize;

  const ElandBottomSheet({
    super.key,
    required this.builder,
    this.initialChildSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize ?? (r.isLandscape ? 0.75 : 0.60),
      minChildSize: 0.25,
      maxChildSize: r.isLandscape ? 0.95 : 0.90,
      expand: false,
      builder: (_, scrollController) {
        return SafeArea(
          top: false,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(r.radius(24)),
            ),
            child: Container(
              decoration: _sheetDecoration(theme, r),
              child: Column(
                children: [
                  const _SheetHandle(),
                  Expanded(child: builder(scrollController)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Opens a content-sized sheet in the same style as [ElandBottomSheet]:
/// handle, plain uppercase title, then [builder]'s content.
Future<T?> showElandSheet<T>({
  required BuildContext context,
  String? title,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final r = ElandResponsive(sheetContext);
      return Container(
        decoration: _sheetDecoration(theme, r),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SheetHandle(),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    r.pageHorizontalPadding,
                    r.spacing(6),
                    r.pageHorizontalPadding,
                    r.spacing(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (title != null) ...[
                        Text(
                          title.toUpperCase(),
                          style: TextStyle(
                            fontSize: r.font(14),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: r.spacing(12)),
                      ],
                      builder(sheetContext),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// One tappable line of a sheet list, separated from the next by a hairline.
class ElandSheetLine extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final bool last;

  const ElandSheetLine({
    super.key,
    this.icon,
    required this.label,
    required this.onTap,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: r.spacing(15)),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: theme.colorScheme.primary, size: r.icon(22)),
              SizedBox(width: r.spacing(16)),
            ],
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: r.font(14),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
