import 'dart:async';
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

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: 320,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: value - min),
                  itemExtent: 50,
                  onSelectedItemChanged: (index) {
                    tempValue = index + min;
                    HapticFeedback.selectionClick();
                  },
                  children: List.generate(
                    max - min + 1,
                        (index) => Center(
                      child: Text(
                        "${index + min}",
                        style: TextStyle(color: theme.textTheme.headlineLarge?.color, fontSize: 28),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    onChanged(tempValue);
                    Navigator.pop(context);
                  },
                  child: Text(ElandStrings.of('ok_btn'),
                      style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 18, fontWeight: FontWeight.bold)
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

    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 14,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RepeatableButton(
              icon: Icons.remove,
              onPressed: () => value > min ? onChanged(value - 1) : null,
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100),
              child: GestureDetector(
                onTap: () => _showPickerDialog(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "$value",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textTheme.headlineLarge?.color,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
            _RepeatableButton(
              icon: Icons.add,
              onPressed: () => value < max ? onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _RepeatableButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _RepeatableButton({required this.icon, required this.onPressed});

  @override
  State<_RepeatableButton> createState() => _RepeatableButtonState();
}

class _RepeatableButtonState extends State<_RepeatableButton> {
  Timer? _timer;
  int _counter = 0;

  void _onTapDown(TapDownDetails details) {
    HapticFeedback.lightImpact();
    widget.onPressed();
    _timer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      _counter++;
      widget.onPressed();
      if (_counter % 3 == 0) HapticFeedback.selectionClick();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _counter = 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (_) => _stopTimer(),
      onTapCancel: _stopTimer,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.dividerColor, width: 1.5),
        ),
        child: Icon(widget.icon, color: theme.colorScheme.primary, size: 24),
      ),
    );
  }
}