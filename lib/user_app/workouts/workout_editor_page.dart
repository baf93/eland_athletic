import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/eland_responsive.dart';
import '../../common/strings.dart';
import '../../common/timer_core/models/timer_block.dart';
import '../../common/widgets/eland_dialog.dart';
import '../../common/widgets/pill_badge.dart';
import '../../common/widgets/primary_action_button.dart';
import '../../common/workouts/models.dart';
import '../../common/workouts/providers.dart';
import '../../common/workouts/ui/eland_ui.dart';
import 'block_editor_sheet.dart';

/// Create (workout == null) or edit a custom workout.
class WorkoutEditorPage extends ConsumerStatefulWidget {
  final CustomWorkout? workout;

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
              widget.workout == null ? 'new_workout' : 'edit_workout'),
          onBack: _confirmLeave,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
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
                              ElandTextField(
                                controller: _name,
                                label: ElandStrings.of('workout_name'),
                                hint: ElandStrings.of('workout_name_hint'),
                                maxLength: 40,
                                autofocus: widget.workout == null,
                                onChanged: (_) => _markDirty(),
                              ),
                              SizedBox(height: r.spacing(14)),
                              ElandTextField(
                                controller: _notes,
                                label: ElandStrings.of('workout_notes'),
                                hint: ElandStrings.of('workout_notes_hint'),
                                maxLines: 3,
                                maxLength: 300,
                                onChanged: (_) => _markDirty(),
                              ),
                              ElandSectionLabel(
                                '${ElandStrings.of('phases')} (${_blocks.length})',
                                trailing: PillBadge(
                                  text: TimerBlock.formatDuration(_totalSeconds),
                                ),
                              ),
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
                                _blocks.insert(
                                    newIndex, _blocks.removeAt(oldIndex));
                                _dirty = true;
                              });
                            },
                            itemBuilder: (context, index) {
                              final block = _blocks[index];
                              return Padding(
                                key: ObjectKey(block),
                                padding: EdgeInsets.only(bottom: r.spacing(10)),
                                child: _BlockTile(
                                  index: index,
                                  block: block,
                                  onTap: () => _editBlock(index),
                                  onDelete: () => setState(() {
                                    _blocks.removeAt(index);
                                    _dirty = true;
                                  }),
                                ),
                              );
                            },
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            r.pageHorizontalPadding,
                            r.spacing(4),
                            r.pageHorizontalPadding,
                            r.spacing(24),
                          ),
                          sliver: SliverToBoxAdapter(
                            child: OutlinedButton.icon(
                              onPressed: _addBlock,
                              icon: const Icon(Icons.add_rounded),
                              label: Text(
                                ElandStrings.of('add_phase').toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.primary,
                                minimumSize: Size.fromHeight(r.spacing(52)),
                                side: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(r.radius(16)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
      ),
    );
  }
}

class _BlockTile extends StatelessWidget {
  final int index;
  final TimerBlock block;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BlockTile({
    required this.index,
    required this.block,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final subtitle = [
      if (block.name?.trim().isNotEmpty ?? false) block.typeLabel,
      block.settingsLabel,
    ].join(' · ');

    return ElandOutlinedCard(
      onTap: onTap,
      padding: EdgeInsets.fromLTRB(
          r.spacing(14), r.spacing(10), r.spacing(4), r.spacing(10)),
      borderColor: block.isValid ? null : Colors.redAccent,
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: EdgeInsets.only(right: r.spacing(10)),
              child: Icon(Icons.drag_indicator_rounded,
                  color: theme.textTheme.bodyMedium?.color),
            ),
          ),
          Icon(timerTypeIcon(block.type),
              color: theme.colorScheme.primary, size: r.icon(22)),
          SizedBox(width: r.spacing(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.displayTitle.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: r.font(14),
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: r.spacing(2)),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: r.font(12),
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                if (block.notes?.trim().isNotEmpty ?? false)
                  Text(
                    block.notes!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: r.font(12),
                      fontStyle: FontStyle.italic,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: ElandStrings.of('delete_btn'),
            icon: Icon(Icons.close_rounded,
                color: theme.textTheme.bodyMedium?.color),
            onPressed: () {
              HapticFeedback.lightImpact();
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}
