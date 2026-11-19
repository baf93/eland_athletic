import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/eland_responsive.dart';
import '../../common/strings.dart';
import '../../common/timer_core/models/timer_block.dart';
import '../../common/workouts/models.dart';
import '../../common/workouts/providers.dart';
import '../../common/workouts/ui/eland_ui.dart';
import 'phase_widgets.dart';
import 'workout_detail_page.dart';
import 'workout_editor_page.dart';

class MyWorkoutsPage extends ConsumerWidget {
  /// true when shown as a tab of the home (no back button).
  final bool embedded;

  const MyWorkoutsPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final workouts = ref.watch(customWorkoutsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: elandAppBar(
        context,
        ElandStrings.of('my_workouts_title'),
        showBack: !embedded,
        actions: [
          IconButton(
            tooltip: ElandStrings.of('new_workout'),
            icon: Icon(Icons.add_rounded, size: r.icon(28)),
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WorkoutEditorPage()),
              );
            },
          ),
          SizedBox(width: r.spacing(4)),
        ],
      ),
      body: SafeArea(
        child: workouts.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (items) {
            if (items.isEmpty) {
              return ElandEmptyState(
                icon: Icons.playlist_add_rounded,
                text: ElandStrings.of('my_workouts_empty'),
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    r.pageHorizontalPadding,
                    r.spacing(8),
                    r.pageHorizontalPadding,
                    r.spacing(24),
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => SizedBox(height: r.cardGap),
                  itemBuilder: (context, index) =>
                      _WorkoutCard(workout: items[index]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final CustomWorkout workout;

  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final muted = theme.textTheme.bodyMedium?.color;

    return ElandOutlinedCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WorkoutDetailPage(workoutId: workout.id),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        r.spacing(18),
        r.spacing(16),
        r.spacing(18),
        r.spacing(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: r.font(16),
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: r.spacing(3)),
                    Row(
                      children: [
                        Text(
                          '${workout.blocks.length} ${ElandStrings.of(workout.blocks.length == 1 ? 'phase_count_one' : 'phases_count')}',
                          style: TextStyle(fontSize: r.font(12), color: muted),
                        ),
                        if (workout.reminder?.isActive ?? false) ...[
                          SizedBox(width: r.spacing(8)),
                          Icon(
                            Icons.notifications_none_rounded,
                            size: r.icon(14),
                            color: muted,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                TimerBlock.formatDuration(workout.totalSeconds),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: r.font(20),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          SizedBox(height: r.spacing(12)),
          PhaseStrip(blocks: workout.blocks),
        ],
      ),
    );
  }
}
