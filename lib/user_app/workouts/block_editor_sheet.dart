import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/eland_responsive.dart';
import '../../common/strings.dart';
import '../../common/timer_core/models/timer_block.dart';
import '../../common/timer_core/models/timercore_enums.dart';
import '../../common/widgets/pill_badge.dart';
import '../../common/widgets/primary_action_button.dart';
import '../../common/widgets/timer_setting_selector.dart';
import '../../common/workouts/ui/eland_ui.dart';

IconData timerTypeIcon(TimerType type) {
  switch (type) {
    case TimerType.tabata:
      return Icons.fitness_center_rounded;
    case TimerType.emom:
      return Icons.loop_rounded;
    case TimerType.amrap:
      return Icons.all_inclusive_rounded;
    case TimerType.fortime:
      return Icons.timer_10_outlined;
    case TimerType.countdown:
      return Icons.hourglass_bottom_rounded;
    case TimerType.rest:
      return Icons.self_improvement_rounded;
    case TimerType.preparation:
      return Icons.directions_run_rounded;
  }
}

/// Bottom sheet listing the timer types; returns the chosen one.
Future<TimerType?> showTimerTypePicker(BuildContext context) {
  final theme = Theme.of(context);
  return showModalBottomSheet<TimerType>(
    context: context,
    backgroundColor: theme.scaffoldBackgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      side: BorderSide(color: theme.dividerColor),
    ),
    builder: (sheetContext) {
      final r = ElandResponsive(sheetContext);
      return SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            r.pageHorizontalPadding,
            r.spacing(8),
            r.pageHorizontalPadding,
            r.spacing(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElandSectionLabel(ElandStrings.of('choose_phase')),
              for (final type in TimerBlock.editableTypes) ...[
                ElandOutlinedCard(
                  onTap: () => Navigator.pop(sheetContext, type),
                  child: Row(
                    children: [
                      Icon(timerTypeIcon(type),
                          color: theme.colorScheme.primary, size: r.icon(24)),
                      SizedBox(width: r.spacing(18)),
                      Expanded(
                        child: Text(
                          ElandStrings.of(TimerBlock.typeLabelKey(type))
                              .toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: r.font(15),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: r.spacing(10)),
              ],
            ],
          ),
        ),
      );
    },
  );
}

/// Full-screen editor of one phase; returns the edited block or null.
Future<TimerBlock?> showBlockEditor(BuildContext context, TimerBlock block) {
  return Navigator.of(context).push<TimerBlock>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => BlockEditorPage(initial: block),
    ),
  );
}

class BlockEditorPage extends StatefulWidget {
  final TimerBlock initial;

  const BlockEditorPage({super.key, required this.initial});

  @override
  State<BlockEditorPage> createState() => _BlockEditorPageState();
}

class _BlockEditorPageState extends State<BlockEditorPage> {
  late TimerBlock _block;
  late final TextEditingController _name;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    // Start from the defaults so every field has a value.
    _block = TimerBlock.defaultsFor(widget.initial.type).copyWith(
      params: {
        ...TimerBlock.defaults[widget.initial.type] ?? const {},
        ...widget.initial.params,
      },
      name: widget.initial.name,
      notes: widget.initial.notes,
    );
    _name = TextEditingController(text: widget.initial.name ?? '');
    _notes = TextEditingController(text: widget.initial.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    if (!_block.isValid) {
      showElandSnack(context, ElandStrings.of('invalid_phase'));
      return;
    }
    HapticFeedback.mediumImpact();
    final name = _name.text.trim();
    final notes = _notes.text.trim();
    Navigator.pop(
      context,
      _block.copyWith(
        name: name.isEmpty ? null : name,
        clearName: name.isEmpty,
        notes: notes.isEmpty ? null : notes,
        clearNotes: notes.isEmpty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final fields = TimerBlock.fieldsFor(_block.type);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: elandAppBar(context, _block.typeLabel),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: r.pagePadding,
                children: [
                  Center(
                    child: PillBadge(
                      text:
                          '${ElandStrings.of('total_time').toUpperCase()}: ${TimerBlock.formatDuration(_block.totalSeconds)}',
                    ),
                  ),
                  SizedBox(height: r.spacing(20)),
                  for (final field in fields) ...[
                    TimerSettingSelector(
                      label: field.label,
                      value: _block.param(field.key),
                      min: field.min,
                      max: field.max,
                      onChanged: (v) =>
                          setState(() => _block = _block.withParam(field.key, v)),
                    ),
                    SizedBox(height: r.settingsGap),
                  ],
                  SizedBox(height: r.spacing(12)),
                  ElandTextField(
                    controller: _name,
                    label: ElandStrings.of('phase_name'),
                    hint: ElandStrings.of('phase_name_hint'),
                    maxLength: 30,
                  ),
                  SizedBox(height: r.spacing(16)),
                  ElandTextField(
                    controller: _notes,
                    label: ElandStrings.of('phase_notes'),
                    hint: ElandStrings.of('phase_notes_hint'),
                    maxLines: 4,
                    maxLength: 300,
                  ),
                  SizedBox(height: r.spacing(24)),
                ],
              ),
            ),
            Padding(
              padding: r.bottomButtonPadding,
              child: PrimaryActionButton(
                height: r.primaryButtonHeight,
                label: ElandStrings.of('save_btn'),
                icon: Icons.check_rounded,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
