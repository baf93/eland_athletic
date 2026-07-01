import 'dart:async';
import 'dart:ui';

import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../strings.dart';

class TimerSettingSelector extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const TimerSettingSelector({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 999,
  });

  void _showPickerDialog(BuildContext context) {
    HapticFeedback.lightImpact();

    int tempValue = value;
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: r.byUsableHeight(
            0.38,
            min: 260,
            max: 360,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(r.radius(16)),
            ),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: r.spacing(12),
                  bottom: r.compactGap,
                ),
                width: r.spacing(40),
                height: r.spacing(4),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(r.radius(2)),
                ),
              ),

              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: value - min,
                  ),
                  itemExtent: r.spacing(46),
                  onSelectedItemChanged: (index) {
                    tempValue = index + min;
                    HapticFeedback.selectionClick();
                  },
                  children: List.generate(
                    max - min + 1,
                        (index) => Center(
                      child: Text(
                        "${index + min}",
                        style: TextStyle(
                          color: theme.textTheme.headlineLarge?.color,
                          fontSize: r.font(24),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(r.spacing(16)),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      minimumSize: Size.fromHeight(
                        r.primaryButtonHeight.clamp(48.0, 60.0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r.radius(12)),
                      ),
                    ),
                    onPressed: () {
                      onChanged(tempValue);
                      Navigator.pop(context);
                    },
                    child: Text(
                      ElandStrings.of('ok_btn'),
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: r.font(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: r.font(14),
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        SizedBox(height: r.sectionGap),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RepeatableButton(
              icon: Icons.remove,
              onPressed: value > min ? () => onChanged(value - 1) : null,
            ),

            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: r.spacing(90),
              ),
              child: GestureDetector(
                onTap: () => _showPickerDialog(context),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.spacing(14),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "$value",
                      style: TextStyle(
                        color: theme.textTheme.headlineLarge?.color,
                        fontSize: r.font(
                          40,
                          minScale: 0.9,
                          maxScale: 1.1,
                        ),
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            _RepeatableButton(
              icon: Icons.add,
              onPressed: value < max ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _RepeatableButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _RepeatableButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_RepeatableButton> createState() => _RepeatableButtonState();
}

class _RepeatableButtonState extends State<_RepeatableButton> {
  Timer? _timer;
  int _counter = 0;

  void _start() {
    if (widget.onPressed == null) return;

    HapticFeedback.lightImpact();
    widget.onPressed!();

    _timer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      _counter++;
      widget.onPressed!();

      if (_counter % 3 == 0) {
        HapticFeedback.selectionClick();
      }
    });
  }

  void _stop() {
    _timer?.cancel();
    _counter = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    final buttonSize = r.icon(
      48,
      minScale: 0.9,
      maxScale: 1.1,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTapDown: (_) => _start(),
        onTapUp: (_) => _stop(),
        onTapCancel: _stop,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.dividerColor,
              width: 1.5,
            ),
          ),
          child: Icon(
            widget.icon,
            color: theme.colorScheme.primary,
            size: r.icon(22),
          ),
        ),
      ),
    );
  }
}