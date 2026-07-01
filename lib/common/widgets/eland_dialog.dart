import 'package:eland_athletic/common/eland_responsive.dart';
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
  final r = ElandResponsive(context);

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(r.radius(10)),
  );

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: r.pageHorizontalPadding,
          vertical: r.spacing(24),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r.radius(16)),
          side: BorderSide(
            color: theme.dividerColor,
            width: 1.5,
          ),
        ),
        title: Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w900,
            fontSize: r.font(18),
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: r.font(16),
              height: 1.3,
            ),
          ),
        ),
        actionsPadding: EdgeInsets.fromLTRB(
          r.spacing(12),
          0,
          r.spacing(12),
          r.spacing(12),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: r.spacing(12),
            runSpacing: r.settingsGap,
            children: [
              if (cancelText != null)
                SizedBox(
                  width: r.byWidth(0.36, min: 120, max: 150),
                  height: r.spacing(44),
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
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        cancelText.toUpperCase(),
                        style: TextStyle(
                          color: theme.textTheme.headlineLarge?.color,
                          fontSize: r.font(14),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(
                width: r.byWidth(0.36, min: 120, max: 150),
                height: r.spacing(44),
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                    onResult(true);
                  },
                  style: OutlinedButton.styleFrom(
                    shape: buttonShape,
                    side: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      confirmText.toUpperCase(),
                      style: TextStyle(
                        color: theme.textTheme.headlineLarge?.color,
                        fontSize: r.font(14),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}