import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: 320,
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
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
                        style: const TextStyle(color: Colors.white, fontSize: 28),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    onChanged(tempValue);
                    Navigator.pop(context);
                  },
                  child: const Text("OK", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
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
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
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
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
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
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (_) => _stopTimer(),
      onTapCancel: _stopTimer,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade700, width: 1.5),
        ),
        child: Icon(widget.icon, color: Colors.orange, size: 24),
      ),
    );
  }
}