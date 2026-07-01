import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:flutter/material.dart';

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
      initialChildSize:
      initialChildSize ?? (r.isLandscape ? 0.75 : 0.60),
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
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(r.radius(24)),
                ),
                border: Border.all(
                  color: theme.dividerColor,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: r.spacing(r.isLandscape ? 10 : 14),
                    ),
                    width: r.byWidth(
                      0.10,
                      min: 32,
                      max: 42,
                    ),
                    height: r.spacing(
                      5,
                      minScale: 0.8,
                      maxScale: 1.2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(r.radius(6)),
                    ),
                  ),
                  Expanded(
                    child: builder(scrollController),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}