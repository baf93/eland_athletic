import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/eland_responsive.dart';
import '../../common/strings.dart';
import '../../common/theme.dart';
import '../../common/timer_core/models/timer_block.dart';
import '../../common/widgets/eland_dialog.dart';
import '../../common/workouts/models.dart';
import '../../common/workouts/providers.dart';
import '../../common/workouts/ui/eland_ui.dart';
import 'workout_detail_page.dart';

/// Training log: month calendar, monthly totals and the sessions grouped by
/// day with their results. Tapping a day of the calendar filters the list.
class HistoryPage extends ConsumerStatefulWidget {
  /// true when shown as a tab of the home (no back button).
  final bool embedded;

  const HistoryPage({super.key, this.embedded = false});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  late DateTime _month;
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    // Opens on today; tap it again to see the whole month.
    _selectedDay = now.day;
  }

  void _shiftMonth(int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      _selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final history = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: elandAppBar(context, ElandStrings.of('history_title'),
          showBack: !widget.embedded),
      body: SafeArea(
        child: history.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (logs) {
            if (logs.isEmpty) {
              return ElandEmptyState(
                icon: Icons.history_rounded,
                text: ElandStrings.of('history_empty'),
              );
            }

            final month = MonthStats.from(logs, _month.year, _month.month);
            final streak = HistoryStats.from(logs).weekStreak;
            final records = personalBestIds(logs);
            final visible = logs.where((l) {
              final d = l.completedAt;
              if (d.year != _month.year || d.month != _month.month) {
                return false;
              }
              return _selectedDay == null || d.day == _selectedDay;
            }).toList();

            final children = <Widget>[
              _MonthHeader(
                month: _month,
                onPrevious: () => _shiftMonth(-1),
                onNext: _month.year == DateTime.now().year &&
                        _month.month == DateTime.now().month
                    ? null
                    : () => _shiftMonth(1),
              ),
              SizedBox(height: r.spacing(14)),
              Row(
                children: [
                  _Stat(
                    value: '${month.sessions}',
                    label: ElandStrings.of('stats_sessions'),
                  ),
                  _Stat(
                    value: _hoursMinutes(month.seconds),
                    label: ElandStrings.of('stats_time'),
                  ),
                  _Stat(
                    value: '$streak',
                    label: ElandStrings.of('stats_week_streak'),
                    accent: true,
                  ),
                ],
              ),
              SizedBox(height: r.spacing(18)),
              _MonthCalendar(
                month: _month,
                activeDays: month.activeDays,
                selectedDay: _selectedDay,
                onDayTap: (day) {
                  HapticFeedback.selectionClick();
                  setState(
                      () => _selectedDay = _selectedDay == day ? null : day);
                },
              ),
              SizedBox(height: r.spacing(6)),
              // A selected day without sessions still shows which day it is.
              if (_selectedDay != null && visible.isEmpty)
                ElandSectionLabel(formatLogDate(
                    DateTime(_month.year, _month.month, _selectedDay!))),
            ];

            for (var i = 0; i < visible.length; i++) {
              final log = visible[i];
              final previous = i > 0 ? visible[i - 1] : null;
              if (previous == null ||
                  previous.completedAt.day != log.completedAt.day) {
                children.add(ElandSectionLabel(formatLogDate(log.completedAt)));
              }
              children.add(_LogLine(log: log, record: records.contains(log.id)));
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    r.pageHorizontalPadding,
                    r.spacing(4),
                    r.pageHorizontalPadding,
                    r.spacing(32),
                  ),
                  children: children,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static String _hoursMinutes(int seconds) {
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '${minutes}m';
    return '${minutes ~/ 60}h ${(minutes % 60).toString().padLeft(2, '0')}';
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  const _MonthHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final muted = theme.textTheme.bodyMedium?.color;
    final label = month.year == DateTime.now().year
        ? ElandStrings.of('month_${month.month}')
        : '${ElandStrings.of('month_${month.month}')} ${month.year}';

    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: Icon(Icons.chevron_left_rounded, color: muted),
        ),
        Expanded(
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: r.font(14),
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: Icon(Icons.chevron_right_rounded,
              color: onNext == null ? Colors.transparent : muted),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final bool accent;

  const _Stat({required this.value, required this.label, this.accent = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: r.font(26),
              fontWeight: FontWeight.w900,
              color: accent ? theme.colorScheme.primary : null,
            ),
          ),
          SizedBox(height: r.spacing(2)),
          // Scales down instead of cutting longer translations.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                fontSize: r.font(10),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Month grid starting on Monday; training days are filled orange.
class _MonthCalendar extends StatelessWidget {
  final DateTime month;
  final Set<int> activeDays;
  final int? selectedDay;
  final ValueChanged<int> onDayTap;

  const _MonthCalendar({
    required this.month,
    required this.activeDays,
    required this.selectedDay,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final muted = theme.textTheme.bodyMedium?.color;
    final border =
        theme.extension<ElandCustomColors>()?.cardBorder ?? theme.dividerColor;
    final primary = theme.colorScheme.primary;

    final now = DateTime.now();
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final offset = DateTime(month.year, month.month, 1).weekday - 1;
    final cells = offset + daysInMonth;
    final rows = (cells / 7).ceil();

    Widget cell(int index) {
      final day = index - offset + 1;
      if (day < 1 || day > daysInMonth) return const SizedBox.shrink();
      final active = activeDays.contains(day);
      final selected = selectedDay == day;
      final isToday = now.year == month.year &&
          now.month == month.month &&
          now.day == day;
      final future = DateTime(month.year, month.month, day).isAfter(now);

      return GestureDetector(
        onTap: future ? null : () => onDayTap(day),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: active
                ? (selectedDay == null || selected
                    ? primary
                    : primary.withAlpha(90))
                : null,
            borderRadius: BorderRadius.circular(r.radius(8)),
            border: Border.all(
              color: selected
                  ? theme.textTheme.headlineLarge?.color ?? Colors.white
                  : isToday && !active
                      ? muted ?? border
                      : Colors.transparent,
              width: selected ? 2 : 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: r.font(12),
              fontWeight: active ? FontWeight.w900 : FontWeight.w600,
              color: active
                  ? Colors.black
                  : selected
                      ? theme.textTheme.headlineLarge?.color
                      : future
                      ? muted?.withAlpha(70)
                      : muted,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            for (var d = 1; d <= 7; d++)
              Expanded(
                child: Text(
                  ElandStrings.of('weekday_$d').substring(0, 1).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: r.font(10),
                    fontWeight: FontWeight.w800,
                    color: muted,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: r.spacing(6)),
        for (var row = 0; row < rows; row++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.15,
                    child: cell(row * 7 + col),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// One session: name on the left, the result (or the duration) on the right.
class _LogLine extends ConsumerWidget {
  final WorkoutLog log;
  final bool record;

  const _LogLine({required this.log, required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final muted = theme.textTheme.bodyMedium?.color;
    final border =
        theme.extension<ElandCustomColors>()?.cardBorder ?? theme.dividerColor;

    final results = <String>[
      if (log.amrapRounds != null)
        '${log.amrapRounds} ${ElandStrings.of('result_rounds')}',
      for (final result in log.forTimeResults)
        result.overCap
            ? ElandStrings.of('result_over_cap')
            : TimerBlock.formatDuration(result.seconds),
    ];
    final duration = TimerBlock.formatDuration(log.activeSeconds);

    return InkWell(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        showElandDialog(
          context: context,
          title: ElandStrings.of('delete_log_title'),
          content: ElandStrings.of('delete_log_desc'),
          cancelText: ElandStrings.of('cancel_btn'),
          confirmText: ElandStrings.of('delete_btn'),
          onResult: (confirmed) {
            if (confirmed) ref.read(historyProvider.notifier).delete(log.id);
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: r.spacing(14)),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: border, width: 0.8)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                log.title.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: r.font(14),
                  letterSpacing: 1.1,
                ),
              ),
            ),
            if (results.isNotEmpty) ...[
              Text(
                duration,
                style: TextStyle(fontSize: r.font(13), color: muted),
              ),
              SizedBox(width: r.spacing(14)),
              Text(
                results.join(' · ').toUpperCase(),
                style: TextStyle(
                  fontSize: r.font(14),
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
              ),
            ] else
              Text(
                duration,
                style: TextStyle(
                  fontSize: r.font(14),
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            if (record) ...[
              SizedBox(width: r.spacing(6)),
              Tooltip(
                message: ElandStrings.of('personal_best'),
                child: Icon(Icons.emoji_events_rounded,
                    size: r.icon(16), color: theme.colorScheme.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
