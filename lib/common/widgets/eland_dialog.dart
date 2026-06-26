import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showElandDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String confirmText,
  String? cancelText,
  required Function(bool) onResult,
}) {
  final theme = Theme.of(context);
  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(6));

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 24.0),
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor, width: 1.5),
      ),
      title: Text(
        title.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18),
      ),
      content: Text(
        content,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: theme.textTheme.bodyMedium?.color,
          fontSize: 16,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (cancelText != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      onResult(false);
                    },
                    style: OutlinedButton.styleFrom(
                      shape: buttonShape,
                      side: BorderSide(
                        color: theme.dividerColor,
                        width: 1,
                      ),
                    ),
                    child: Text(cancelText,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.textTheme.headlineLarge?.color, fontSize: 14),
                    ),
                  ),
                ),

              if (cancelText != null) const SizedBox(width: 14),

              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                    onResult(true);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: buttonShape,
                    side: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  child: Text(confirmText,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.textTheme.headlineLarge?.color, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}