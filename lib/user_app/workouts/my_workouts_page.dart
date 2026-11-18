import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/eland_responsive.dart';
import '../../common/strings.dart';
import '../../common/timer_core/models/timer_block.dart';
import '../../common/workouts/models.dart';
import '../../common/workouts/providers.dart';
import '../../common/workouts/ui/eland_ui.dart';
import '../../common/workouts/workout_launcher.dart';
import 'block_editor_sheet.dart';
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
      appBar: elandAppBar(context, ElandStrings.of('my_workouts_title'),
          showBack: !embedded),
      floatingActionButton: FloatingActionButton(
        tooltip: ElandStrings.of('new_workout'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.black,
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const WorkoutEditorPage(),
          ));
        },
        child: const Icon(Icons.add_rounded, size: 30),
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
                    r.spacing(96),
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
    final icons = workout.blocks.map((b) => b.type).toSet().take(4);

    return ElandOutlinedCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => WorkoutDetailPage(workoutId: workout.id),
      )),
      padding: EdgeInsets.fromLTRB(
          r.spacing(18), r.spacing(14), r.spacing(8), r.spacing(14)),
      child: Row(
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
                SizedBox(height: r.spacing(6)),
                Row(
                  children: [
                    for (final type in icons) ...[
                      Icon(timerTypeIcon(type),
                          size: r.icon(16), color: theme.colorScheme.primary),
                      SizedBox(width: r.spacing(6)),
                    ],
                    SizedBox(width: r.spacing(4)),
                    Flexible(
                      child: Text(
                        '${workout.blocks.length} ${ElandStrings.of('phases_count')} · ${TimerBlock.formatDuration(workout.totalSeconds)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: r.font(12),
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
                if (workout.reminder?.isActive ?? false) ...[
                  SizedBox(height: r.spacing(4)),
                  Row(
                    children: [
                      Icon(Icons.notifications_active_rounded,
                          size: r.icon(14),
                          color: theme.textTheme.bodyMedium?.color),
                      SizedBox(width: r.spacing(6)),
                      Flexible(
                        child: Text(
                          reminderLabel(workout.reminder),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: r.font(12),
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: ElandStrings.of('start_btn'),
            iconSize: r.icon(36),
            color: theme.colorScheme.primary,
            icon: const Icon(Icons.play_circle_fill_rounded),
            onPressed: () {
              HapticFeedback.mediumImpact();
              WorkoutLauncher.launchWorkout(context, workout);
            },
          ),
        ],
      ),
    );
  }
}
