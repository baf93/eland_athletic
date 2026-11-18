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
import 'workout_detail_page.dart';

class HistoryPage extends ConsumerWidget {
  /// true when shown as a tab of the home (no back button).
  final bool embedded;

  const HistoryPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final history = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: elandAppBar(context, ElandStrings.of('history_title'),
          showBack: !embedded),
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
            final stats = HistoryStats.from(logs);
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    r.pageHorizontalPadding,
                    r.spacing(8),
                    r.pageHorizontalPadding,
                    r.spacing(32),
                  ),
                  itemCount: logs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return _StatsHeader(stats: stats);
                    final log = logs[index - 1];
                    final previous = index > 1 ? logs[index - 2] : null;
                    final newDay = previous == null ||
                        !_sameDay(previous.completedAt, log.completedAt);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (newDay)
                          ElandSectionLabel(formatLogDate(log.completedAt)),
                        Padding(
                          padding: EdgeInsets.only(bottom: r.spacing(10)),
                          child: _LogCard(log: log),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _StatsHeader extends StatelessWidget {
  final HistoryStats stats;

  const _StatsHeader({required this.stats});

  @override
  Widget build(BuildContext context) {
    final r = ElandResponsive(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElandSectionLabel(ElandStrings.of('stats_this_week')),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '${stats.workoutsThisWeek}',
                label: ElandStrings.of('stats_workouts'),
              ),
            ),
            SizedBox(width: r.spacing(10)),
            Expanded(
              child: _StatTile(
                value: '${(stats.secondsThisWeek / 60).round()}',
                label: ElandStrings.of('stats_minutes'),
              ),
            ),
            SizedBox(width: r.spacing(10)),
            Expanded(
              child: _StatTile(
                value: '${stats.dayStreak}',
                label: ElandStrings.of('stats_streak'),
              ),
            ),
          ],
        ),
        SizedBox(height: r.spacing(8)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;

  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    return ElandOutlinedCard(
      padding: EdgeInsets.symmetric(
          vertical: r.spacing(14), horizontal: r.spacing(8)),
      child: Column(
        children: [
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontSize: r.font(28),
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Text(
            label.toUpperCase(),
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: r.font(10),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogCard extends ConsumerWidget {
  final WorkoutLog log;

  const _LogCard({required this.log});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final time =
        '${log.completedAt.hour.toString().padLeft(2, '0')}:${log.completedAt.minute.toString().padLeft(2, '0')}';

    final results = <String>[
      if (log.amrapRounds != null)
        '${log.amrapRounds} ${ElandStrings.of('result_rounds')}',
      for (final r in log.forTimeResults)
        '${TimerBlock.formatDuration(r.seconds)}${r.overCap ? ' (${ElandStrings.of('result_over_cap')})' : ''}',
    ];

    return ElandOutlinedCard(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  log.title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: r.font(15),
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Text(
                TimerBlock.formatDuration(log.activeSeconds),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: r.font(15),
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: r.spacing(4)),
          Text(
            [time, ...log.phases].join(' · '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: r.font(12),
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          if (results.isNotEmpty) ...[
            SizedBox(height: r.spacing(8)),
            Wrap(
              spacing: r.spacing(8),
              runSpacing: r.spacing(6),
              children: [
                for (final result in results)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: r.spacing(10), vertical: r.spacing(4)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(r.radius(20)),
                      color: theme.colorScheme.primary.withAlpha(35),
                    ),
                    child: Text(
                      result.toUpperCase(),
                      style: TextStyle(
                        fontSize: r.font(11),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
