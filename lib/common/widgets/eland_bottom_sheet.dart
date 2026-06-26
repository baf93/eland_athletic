import 'package:flutter/material.dart';

class ElandBottomSheet extends StatelessWidget {
  final Widget Function(ScrollController scrollController) builder;
  final double initialChildSize;

  const ElandBottomSheet({
    super.key,
    required this.builder,
    this.initialChildSize = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            border: Border.all(color: Theme.of(context).dividerColor)
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 14),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: builder(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }
}