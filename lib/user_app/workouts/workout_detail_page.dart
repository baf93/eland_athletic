import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../common/eland_responsive.dart';
import '../../common/strings.dart';
import '../../common/timer_core/models/timer_block.dart';
import '../../common/widgets/eland_bottom_sheet.dart';
import '../../common/widgets/primary_action_button.dart';
import '../../common/workouts/models.dart';
import '../../common/workouts/providers.dart';
import '../../common/workouts/ui/eland_ui.dart';
import '../../common/workouts/workout_launcher.dart';
import 'phase_widgets.dart';
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

/// Preview of a saved workout: total time, phases, reminder and START.
class WorkoutDetailPage extends ConsumerWidget {
  final String workoutId;

  const WorkoutDetailPage({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final muted = theme.textTheme.bodyMedium?.color;
    final workouts = ref.watch(customWorkoutsProvider).value;

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: elandAppBar(
        context,
        workout.name,
        actions: [
          IconButton(
            tooltip: ElandStrings.of('edit_btn'),
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              HapticFeedback.lightImpact();
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WorkoutEditorPage(workout: workout),
                ),
              );
              if (result == WorkoutEditorPage.deleted && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          SizedBox(width: r.spacing(4)),
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
                    padding: EdgeInsets.fromLTRB(
                      r.pageHorizontalPadding,
                      r.spacing(4),
                      r.pageHorizontalPadding,
                      r.spacing(16),
                    ),
                    children: [
                      Center(
                        child: Text(
                          TimerBlock.formatDuration(workout.totalSeconds),
                          style: TextStyle(
                            fontSize: r.font(60, maxScale: 1.1),
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      if (workout.notes?.trim().isNotEmpty ?? false) ...[
                        SizedBox(height: r.spacing(6)),
                        Text(
                          workout.notes!.trim(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: r.font(14),
                            height: 1.35,
                            color: muted,
                          ),
                        ),
                      ],
                      SizedBox(height: r.spacing(18)),
                      PhaseStrip(blocks: workout.blocks, height: 6),
                      SizedBox(height: r.spacing(8)),
                      for (var i = 0; i < workout.blocks.length; i++)
                        PhaseLine(
                          block: workout.blocks[i],
                          leading: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: r.font(14),
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      _ReminderLine(
                        reminder: workout.reminder,
                        onTap: () => _editReminder(context, ref, workout),
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

  Future<void> _editReminder(
    BuildContext context,
    WidgetRef ref,
    CustomWorkout workout,
  ) async {
    final result = await showElandSheet<_ReminderResult>(
      context: context,
      title: ElandStrings.of('reminder_title'),
      builder: (_) => _ReminderSheet(initial: workout.reminder),
    );
    if (result == null) return;

    if (result.reminder?.isActive ?? false) {
      final status = await Permission.notification.request();
      if (!status.isGranted && context.mounted) {
        showElandSnack(context, ElandStrings.of('reminder_permission'));
      }
    }

    await ref
        .read(customWorkoutsProvider.notifier)
        .save(
          result.reminder == null
              ? workout.copyWith(clearReminder: true)
              : workout.copyWith(reminder: result.reminder),
        );
  }
}

class _ReminderLine extends StatelessWidget {
  final WorkoutReminder? reminder;
  final VoidCallback onTap;

  const _ReminderLine({required this.reminder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final muted = theme.textTheme.bodyMedium?.color;
    final active = reminder?.isActive ?? false;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: r.spacing(16)),
        child: Row(
          children: [
            SizedBox(
              width: r.spacing(28),
              child: Icon(
                active
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_none_rounded,
                size: r.icon(18),
                color: active ? theme.colorScheme.primary : muted,
              ),
            ),
            SizedBox(width: r.spacing(10)),
            Expanded(
              child: Text(
                ElandStrings.of('reminder').toUpperCase(),
                style: TextStyle(
                  fontSize: r.font(13),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: muted,
                ),
              ),
            ),
            Text(
              reminderLabel(reminder).toUpperCase(),
              style: TextStyle(
                fontSize: r.font(13),
                fontWeight: FontWeight.w700,
                color: active ? null : muted,
              ),
            ),
            SizedBox(width: r.spacing(6)),
            Icon(Icons.chevron_right_rounded, size: r.icon(18), color: muted),
          ],
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final muted = theme.textTheme.bodyMedium?.color;
    final primary = theme.colorScheme.primary;

    Widget wheel(int count, int initial, ValueChanged<int> onChanged) =>
        SizedBox(
          width: r.spacing(70),
          child: CupertinoPicker(
            scrollController: FixedExtentScrollController(initialItem: initial),
            itemExtent: r.spacing(44),
            looping: true,
            selectionOverlay: const SizedBox.shrink(),
            onSelectedItemChanged: (i) {
              HapticFeedback.selectionClick();
              onChanged(i);
            },
            children: [
              for (var i = 0; i < count; i++)
                Center(
                  child: Text(
                    i.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: r.font(30),
                      fontWeight: FontWeight.w900,
                      color: theme.textTheme.headlineLarge?.color,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
            ],
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Days as in the History calendar: filled orange when on.
        Row(
          children: [
            for (var d = 1; d <= 7; d++)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(
                      () => _days.contains(d) ? _days.remove(d) : _days.add(d),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: r.spacing(40),
                    margin: const EdgeInsets.all(2.5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _days.contains(d) ? primary : null,
                      borderRadius: BorderRadius.circular(r.radius(8)),
                    ),
                    child: Text(
                      ElandStrings.of('weekday_$d')
                          .substring(0, 1)
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: r.font(13),
                        fontWeight: FontWeight.w900,
                        color: _days.contains(d) ? Colors.black : muted,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: r.spacing(8)),
        SizedBox(
          height: r.spacing(150),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Hairlines around the selected time.
              Container(
                height: r.spacing(44),
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(color: theme.dividerColor),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  wheel(24, _time.hour,
                      (h) => _time = TimeOfDay(hour: h, minute: _time.minute)),
                  Text(
                    ':',
                    style: TextStyle(
                      fontSize: r.font(30),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  wheel(60, _time.minute,
                      (m) => _time = TimeOfDay(hour: _time.hour, minute: m)),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: r.spacing(16)),
        PrimaryActionButton(
          label: ElandStrings.of('save_btn'),
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
              style: TextStyle(
                color: muted,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
      ],
    );
  }
}
