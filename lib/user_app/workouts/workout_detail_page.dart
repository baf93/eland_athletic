import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../common/eland_responsive.dart';
import '../../common/strings.dart';
import '../../common/timer_core/models/timer_block.dart';
import '../../common/widgets/eland_dialog.dart';
import '../../common/widgets/pill_badge.dart';
import '../../common/widgets/primary_action_button.dart';
import '../../common/workouts/models.dart';
import '../../common/workouts/providers.dart';
import '../../common/workouts/ui/eland_ui.dart';
import '../../common/workouts/workout_launcher.dart';
import 'block_editor_sheet.dart';
import 'workout_editor_page.dart';

String reminderLabel(WorkoutReminder? reminder) {
  if (reminder == null || !reminder.isActive) {
    return ElandStrings.of('reminder_off');
  }
  final days = reminder.weekdays
      .map((d) => ElandStrings.of('weekday_$d'))
      .join(' ');
  return '$days · ${reminder.timeLabel}';
}

/// Preview of a saved workout: phases, reminder and START.
class WorkoutDetailPage extends ConsumerWidget {
  final String workoutId;

  const WorkoutDetailPage({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final workouts = ref.watch(customWorkoutsProvider).value;
    final history = ref.watch(historyProvider).value ?? const [];

    final matches = workouts?.where((w) => w.id == workoutId) ?? const [];
    if (matches.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: elandAppBar(context, ElandStrings.of('my_workouts_title')),
        body: workouts == null
            ? const Center(child: CircularProgressIndicator())
            : const SizedBox.shrink(),
      );
    }
    final workout = matches.first;
    final lastLog = history.where((l) => l.workoutId == workout.id).firstOrNull;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: elandAppBar(
        context,
        workout.name,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            color: theme.scaffoldBackgroundColor,
            onSelected: (value) => _onMenu(context, ref, workout, value),
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'edit', child: Text(ElandStrings.of('edit_btn'))),
              PopupMenuItem(
                  value: 'duplicate',
                  child: Text(ElandStrings.of('duplicate_btn'))),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  ElandStrings.of('delete_btn'),
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: ListView(
                    padding: r.pagePadding,
                    children: [
                      Center(
                        child: PillBadge(
                          text:
                              '${ElandStrings.of('total_time').toUpperCase()}: ${TimerBlock.formatDuration(workout.totalSeconds)}',
                        ),
                      ),
                      if (workout.notes?.trim().isNotEmpty ?? false) ...[
                        SizedBox(height: r.spacing(16)),
                        Text(
                          workout.notes!.trim(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: r.font(14),
                            height: 1.35,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                      ElandSectionLabel(
                          '${ElandStrings.of('phases')} (${workout.blocks.length})'),
                      for (var i = 0; i < workout.blocks.length; i++) ...[
                        _PhaseRow(index: i, block: workout.blocks[i]),
                        SizedBox(height: r.spacing(8)),
                      ],
                      ElandSectionLabel(ElandStrings.of('reminder')),
                      ElandOutlinedCard(
                        onTap: () => _editReminder(context, ref, workout),
                        child: Row(
                          children: [
                            Icon(
                              workout.reminder?.isActive ?? false
                                  ? Icons.notifications_active_rounded
                                  : Icons.notifications_none_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: r.spacing(16)),
                            Expanded(
                              child: Text(
                                reminderLabel(workout.reminder).toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: r.font(14),
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: r.icon(14),
                                color: theme.textTheme.bodyMedium?.color),
                          ],
                        ),
                      ),
                      if (lastLog != null) ...[
                        SizedBox(height: r.spacing(18)),
                        Text(
                          '${ElandStrings.of('last_done')}: ${formatLogDate(lastLog.completedAt)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: r.font(12),
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                      SizedBox(height: r.spacing(16)),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: r.bottomButtonPadding,
              child: PrimaryActionButton(
                height: r.primaryButtonHeight,
                label: ElandStrings.of('start_btn'),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  WorkoutLauncher.launchWorkout(context, workout);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onMenu(BuildContext context, WidgetRef ref,
      CustomWorkout workout, String value) async {
    switch (value) {
      case 'edit':
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => WorkoutEditorPage(workout: workout),
        ));
        break;
      case 'duplicate':
        await ref.read(customWorkoutsProvider.notifier).save(
              CustomWorkout.create(
                name:
                    '${workout.name} (${ElandStrings.of('copy_suffix')})',
                blocks: workout.blocks,
                notes: workout.notes,
              ),
            );
        if (context.mounted) {
          showElandSnack(context, ElandStrings.of('workout_saved'));
        }
        break;
      case 'delete':
        showElandDialog(
          context: context,
          title: ElandStrings.of('delete_workout_title'),
          content: ElandStrings.of('delete_workout_desc'),
          cancelText: ElandStrings.of('cancel_btn'),
          confirmText: ElandStrings.of('delete_btn'),
          onResult: (confirmed) async {
            if (!confirmed) return;
            await ref.read(customWorkoutsProvider.notifier).delete(workout.id);
            if (context.mounted) Navigator.of(context).pop();
          },
        );
        break;
    }
  }

  Future<void> _editReminder(
      BuildContext context, WidgetRef ref, CustomWorkout workout) async {
    final result = await showModalBottomSheet<_ReminderResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      builder: (_) => _ReminderSheet(initial: workout.reminder),
    );
    if (result == null) return;

    if (result.reminder?.isActive ?? false) {
      final status = await Permission.notification.request();
      if (!status.isGranted && context.mounted) {
        showElandSnack(context, ElandStrings.of('reminder_permission'));
      }
    }

    await ref.read(customWorkoutsProvider.notifier).save(
          result.reminder == null
              ? workout.copyWith(clearReminder: true)
              : workout.copyWith(reminder: result.reminder),
        );
  }
}

String formatLogDate(DateTime date, {bool withTime = false}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final diff = today.difference(day).inDays;
  final time =
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  String label;
  if (diff == 0) {
    label = ElandStrings.of('today');
  } else if (diff == 1) {
    label = ElandStrings.of('yesterday');
  } else {
    label =
        '${ElandStrings.of('weekday_${date.weekday}')} ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}'
        '${date.year != now.year ? '/${date.year}' : ''}';
  }
  return withTime ? '$label · $time' : label;
}

class _PhaseRow extends StatelessWidget {
  final int index;
  final TimerBlock block;

  const _PhaseRow({required this.index, required this.block});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    return ElandOutlinedCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: r.font(16),
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: r.spacing(16)),
          Icon(timerTypeIcon(block.type),
              size: r.icon(20), color: theme.textTheme.bodyMedium?.color),
          SizedBox(width: r.spacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.displayTitle.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: r.font(14),
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  block.settingsLabel,
                  style: TextStyle(
                    fontSize: r.font(12),
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                if (block.notes?.trim().isNotEmpty ?? false) ...[
                  SizedBox(height: r.spacing(4)),
                  Text(
                    block.notes!.trim(),
                    style: TextStyle(
                      fontSize: r.font(12),
                      fontStyle: FontStyle.italic,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderResult {
  /// null = remove the reminder.
  final WorkoutReminder? reminder;
  const _ReminderResult(this.reminder);
}

class _ReminderSheet extends StatefulWidget {
  final WorkoutReminder? initial;

  const _ReminderSheet({this.initial});

  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  late Set<int> _days;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _days = {...?widget.initial?.weekdays};
    _time = TimeOfDay(
      hour: widget.initial?.hour ?? 18,
      minute: widget.initial?.minute ?? 0,
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final timeLabel =
        '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.spacing(8),
            r.pageHorizontalPadding, r.spacing(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElandSectionLabel(ElandStrings.of('reminder_title')),
            Text(
              ElandStrings.of('reminder_days').toUpperCase(),
              style: TextStyle(
                fontSize: r.font(11),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            SizedBox(height: r.spacing(10)),
            Wrap(
              spacing: r.spacing(8),
              runSpacing: r.spacing(8),
              children: [
                for (var d = 1; d <= 7; d++)
                  ChoiceChip(
                    label: Text(ElandStrings.of('weekday_$d').toUpperCase()),
                    selected: _days.contains(d),
                    showCheckmark: false,
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _days.contains(d)
                          ? Colors.black
                          : theme.textTheme.bodyLarge?.color,
                    ),
                    onSelected: (selected) {
                      HapticFeedback.selectionClick();
                      setState(() => selected ? _days.add(d) : _days.remove(d));
                    },
                  ),
              ],
            ),
            SizedBox(height: r.spacing(18)),
            ElandOutlinedCard(
              onTap: _pickTime,
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, color: theme.colorScheme.primary),
                  SizedBox(width: r.spacing(16)),
                  Expanded(
                    child: Text(
                      ElandStrings.of('reminder_time').toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: r.font(14),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  Text(
                    timeLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: r.font(20),
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: r.spacing(20)),
            PrimaryActionButton(
              height: r.primaryButtonHeight,
              label: ElandStrings.of('save_btn'),
              icon: Icons.check_rounded,
              onPressed: () {
                HapticFeedback.mediumImpact();
                final days = _days.toList()..sort();
                Navigator.pop(
                  context,
                  _ReminderResult(
                    days.isEmpty
                        ? null
                        : WorkoutReminder(
                            weekdays: days,
                            hour: _time.hour,
                            minute: _time.minute,
                          ),
                  ),
                );
              },
            ),
            if (widget.initial != null)
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, const _ReminderResult(null)),
                child: Text(
                  ElandStrings.of('reminder_remove').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
