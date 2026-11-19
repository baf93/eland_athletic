import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/eland_responsive.dart';
import '../../common/strings.dart';
import '../../common/timer_core/models/timer_block.dart';
import '../../common/widgets/eland_dialog.dart';
import '../../common/workouts/models.dart';
import '../../common/workouts/providers.dart';
import '../../common/workouts/ui/eland_ui.dart';
import '../../common/theme.dart';
import 'block_editor_sheet.dart';
import 'phase_widgets.dart';

/// Create (workout == null) or edit a custom workout.
class WorkoutEditorPage extends ConsumerStatefulWidget {
  final CustomWorkout? workout;

  /// Popped by the editor when the workout has been deleted.
  static const deleted = 'deleted';

  const WorkoutEditorPage({super.key, this.workout});

  @override
  ConsumerState<WorkoutEditorPage> createState() => _WorkoutEditorPageState();
}

class _WorkoutEditorPageState extends ConsumerState<WorkoutEditorPage> {
  late final TextEditingController _name;
  late final TextEditingController _notes;
  late List<TimerBlock> _blocks;
  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.workout?.name ?? '');
    _notes = TextEditingController(text: widget.workout?.notes ?? '');
    _blocks = List.of(widget.workout?.blocks ?? const []);
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  int get _totalSeconds => _blocks.fold(0, (s, b) => s + b.totalSeconds);

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _addBlock() async {
    final type = await showTimerTypePicker(context);
    if (type == null || !mounted) return;
    final block = await showBlockEditor(context, TimerBlock.defaultsFor(type));
    if (block == null) return;
    setState(() {
      _blocks.add(block);
      _dirty = true;
    });
  }

  Future<void> _editBlock(int index) async {
    final block = await showBlockEditor(context, _blocks[index]);
    if (block == null) return;
    setState(() {
      _blocks[index] = block;
      _dirty = true;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final name = _name.text.trim();
    if (name.isEmpty) {
      showElandSnack(context, ElandStrings.of('name_required'));
      return;
    }
    if (_blocks.isEmpty) {
      showElandSnack(context, ElandStrings.of('no_phases'));
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _saving = true);

    final notes = _notes.text.trim();
    final existing = widget.workout;
    final workout = existing == null
        ? CustomWorkout.create(
            name: name,
            blocks: _blocks,
            notes: notes.isEmpty ? null : notes,
          )
        : existing.copyWith(name: name, blocks: _blocks, notes: notes);

    await ref.read(customWorkoutsProvider.notifier).save(workout);
    if (!mounted) return;
    _dirty = false;
    Navigator.pop(context, workout);
  }

  void _confirmLeave() {
    if (!_dirty) {
      Navigator.pop(context);
      return;
    }
    showElandDialog(
      context: context,
      title: ElandStrings.of('discard_changes_title'),
      content: ElandStrings.of('discard_changes_desc'),
      cancelText: ElandStrings.of('cancel_btn'),
      confirmText: ElandStrings.of('ok_btn'),
      onResult: (confirmed) {
        if (confirmed) {
          _dirty = false;
          Navigator.pop(context);
        }
      },
    );
  }

  Future<void> _duplicate() async {
    final source = widget.workout!;
    HapticFeedback.lightImpact();
    await ref
        .read(customWorkoutsProvider.notifier)
        .save(
          CustomWorkout.create(
            name: '${source.name} (${ElandStrings.of('copy_suffix')})',
            blocks: source.blocks,
            notes: source.notes,
          ),
        );
    if (mounted) showElandSnack(context, ElandStrings.of('workout_saved'));
  }

  void _delete() {
    showElandDialog(
      context: context,
      title: ElandStrings.of('delete_workout_title'),
      content: ElandStrings.of('delete_workout_desc'),
      cancelText: ElandStrings.of('cancel_btn'),
      confirmText: ElandStrings.of('delete_btn'),
      onResult: (confirmed) async {
        if (!confirmed) return;
        await ref
            .read(customWorkoutsProvider.notifier)
            .delete(widget.workout!.id);
        if (!mounted) return;
        _dirty = false;
        Navigator.of(context).pop(WorkoutEditorPage.deleted);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: elandAppBar(
          context,
          ElandStrings.of(
            widget.workout == null ? 'new_workout' : 'edit_workout',
          ),
          onBack: _confirmLeave,
          actions: [
            TextButton(
              onPressed: _save,
              child: Text(
                ElandStrings.of('save_btn').toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  fontSize: r.font(14),
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            SizedBox(width: r.spacing(4)),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      r.pageHorizontalPadding,
                      r.spacing(8),
                      r.pageHorizontalPadding,
                      0,
                    ),
                    sliver: SliverList.list(
                      children: [
                        _PlainField(
                          controller: _name,
                          hint: ElandStrings.of('workout_name'),
                          fontSize: r.font(24),
                          fontWeight: FontWeight.w800,
                          maxLength: 40,
                          autofocus: widget.workout == null,
                          onChanged: (_) => _markDirty(),
                        ),
                        SizedBox(height: r.spacing(6)),
                        _PlainField(
                          controller: _notes,
                          hint: ElandStrings.of('workout_notes'),
                          fontSize: r.font(14),
                          fontWeight: FontWeight.w500,
                          maxLines: 3,
                          maxLength: 300,
                          onChanged: (_) => _markDirty(),
                        ),
                        ElandSectionLabel(
                          ElandStrings.of('phases'),
                          trailing: Text(
                            TimerBlock.formatDuration(_totalSeconds),
                            style: TextStyle(
                              fontSize: r.font(13),
                              fontWeight: FontWeight.w800,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                        if (_blocks.isNotEmpty)
                          PhaseStrip(blocks: _blocks, height: 6),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.pageHorizontalPadding,
                    ),
                    sliver: SliverReorderableList(
                      itemCount: _blocks.length,
                      onReorderItem: (oldIndex, newIndex) {
                        setState(() {
                          _blocks.insert(newIndex, _blocks.removeAt(oldIndex));
                          _dirty = true;
                        });
                      },
                      itemBuilder: (context, index) {
                        final block = _blocks[index];
                        return Dismissible(
                          key: ObjectKey(block),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: r.spacing(16)),
                            color: Colors.redAccent.withAlpha(40),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                            ),
                          ),
                          onDismissed: (_) {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              _blocks.removeAt(index);
                              _dirty = true;
                            });
                          },
                          child: PhaseLine(
                            block: block,
                            onTap: () => _editBlock(index),
                            leading: ReorderableDragStartListener(
                              index: index,
                              child: Icon(
                                Icons.drag_indicator_rounded,
                                size: r.icon(20),
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      r.pageHorizontalPadding,
                      r.spacing(16),
                      r.pageHorizontalPadding,
                      r.spacing(24),
                    ),
                    sliver: SliverList.list(
                      children: [
                        ElandOutlinedCard(
                          onTap: _addBlock,
                          padding: EdgeInsets.symmetric(
                            vertical: r.spacing(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: r.icon(20),
                                color: theme.colorScheme.primary,
                              ),
                              SizedBox(width: r.spacing(8)),
                              Text(
                                ElandStrings.of('add_phase').toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  fontSize: r.font(13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.workout != null) ...[
                          SizedBox(height: r.spacing(28)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _QuietButton(
                                label: ElandStrings.of('duplicate_btn'),
                                onTap: _duplicate,
                              ),
                              _QuietButton(
                                label: ElandStrings.of('delete_btn'),
                                color: Colors.redAccent,
                                onTap: _delete,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Borderless text field with a single hairline underneath.
class _PlainField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final double fontSize;
  final FontWeight fontWeight;
  final int maxLines;
  final int? maxLength;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  const _PlainField({
    required this.controller,
    required this.hint,
    required this.fontSize,
    required this.fontWeight,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = UnderlineInputBorder(
      borderSide: BorderSide(
        color:
            theme.extension<ElandCustomColors>()?.cardBorder ??
            theme.dividerColor,
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
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: theme.textTheme.bodyMedium?.color?.withAlpha(120),
        ),
        counterText: '',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}

class _QuietButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _QuietButton({required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final r = ElandResponsive(context);
    return TextButton(
      onPressed: onTap,
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: r.font(12),
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }
}
