import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../eland_responsive.dart';
import '../../theme.dart';

/// App bar used by every Eland page (back chevron, bold uppercase title).
PreferredSizeWidget elandAppBar(
  BuildContext context,
  String title, {
  List<Widget>? actions,
  VoidCallback? onBack,
}) {
  final r = ElandResponsive(context);
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new),
      onPressed: () {
        HapticFeedback.lightImpact();
        if (onBack != null) {
          onBack();
        } else {
          Navigator.maybePop(context);
        }
      },
    ),
    title: Text(
      title.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: r.font(18),
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    ),
    centerTitle: true,
    actions: actions,
  );
}

void showElandSnack(BuildContext context, String message) {
  final theme = Theme.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.primary,
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
}

/// Bordered container matching the timer rows of the home page.
class ElandOutlinedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;

  const ElandOutlinedCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final colors = theme.extension<ElandCustomColors>();
    final radius = BorderRadius.circular(r.radius(16));

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        onLongPress: onLongPress,
        child: Container(
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: r.spacing(18),
                vertical: r.spacing(14),
              ),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? colors?.cardBorder ?? theme.dividerColor,
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Small uppercase label in the accent color (section headers).
class ElandSectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const ElandSectionLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    return Padding(
      padding: EdgeInsets.only(top: r.spacing(18), bottom: r.spacing(10)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: r.font(13),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Centered empty state with icon and text.
class ElandEmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  const ElandEmptyState({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.spacing(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: r.icon(56), color: theme.colorScheme.primary),
            SizedBox(height: r.spacing(18)),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: r.font(15),
                height: 1.4,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Text field styled for the dark Eland look.
class ElandTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final int? maxLength;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  const ElandTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final colors = theme.extension<ElandCustomColors>();
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(r.radius(12)),
      borderSide: BorderSide(
        color: colors?.cardBorder ?? theme.dividerColor,
        width: 1.2,
      ),
    );

    return TextField(
      controller: controller,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: 1,
      maxLength: maxLength,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(fontSize: r.font(16), fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label.toUpperCase(),
        hintText: hint,
        counterText: '',
        labelStyle: TextStyle(
          fontSize: r.font(12),
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: theme.colorScheme.primary,
        ),
        floatingLabelStyle: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: theme.colorScheme.primary,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}

/// Dialog with a single text field. Returns the trimmed text, or null.
Future<String?> showElandTextInputDialog({
  required BuildContext context,
  required String title,
  required String label,
  String? hint,
  String initialValue = '',
  required String confirmText,
  required String cancelText,
}) {
  final controller = TextEditingController(text: initialValue);
  final theme = Theme.of(context);
  final r = ElandResponsive(context);

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      void submit() {
        final value = controller.text.trim();
        if (value.isEmpty) return;
        HapticFeedback.mediumImpact();
        Navigator.pop(dialogContext, value);
      }

      return AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r.radius(16)),
          side: BorderSide(color: theme.dividerColor, width: 1.5),
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
        content: ElandTextField(
          controller: controller,
          label: label,
          hint: hint,
          maxLength: 40,
          autofocus: true,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              cancelText.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: theme.textTheme.headlineLarge?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: submit,
            child: Text(
              confirmText.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      );
    },
  ).whenComplete(controller.dispose);
}
