import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../strings.dart';
import '../timer_core/controllers/workout_controller.dart';
import '../timer_core/generators/workout_generator.dart';
import '../timer_core/models/timer_block.dart';
import '../timer_core/models/workout_config.dart';
import '../timer_core/ui/workouts/workout_page.dart';
import 'models.dart';
import 'providers.dart';
import 'ui/eland_ui.dart';

/// Single entry point to start a workout from any page.
class WorkoutLauncher {
  WorkoutLauncher._();

  static Future<void> launchConfigs(
    BuildContext context,
    List<WorkoutConfig> configs,
  ) async {
    if (configs.isEmpty) return;
    final generator = WorkoutGenerator();
    WorkoutController.instance.launchWorkout(
      generator.generate(configs),
      generator.generateUIPhaseSummary(configs),
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/workout'),
        builder: (_) => const WorkoutPage(),
      ),
    );
  }

  /// Quick timer (single block) started from its settings page.
  static Future<void> launchQuickTimer(
    BuildContext context,
    TimerBlock block,
  ) async {
    if (!block.isValid) {
      showElandSnack(context, ElandStrings.of('invalid_phase'));
      return;
    }
    await launchConfigs(context, [
      block.toConfig(
        workoutId: quickTimerId(block.type.name),
        workoutTitle: block.typeLabel.toUpperCase(),
      ),
    ]);
  }

  static Future<void> launchWorkout(
    BuildContext context,
    CustomWorkout workout,
  ) async {
    if (!workout.isValid) {
      showElandSnack(context, ElandStrings.of('invalid_phase'));
      return;
    }
    await launchConfigs(context, workout.toConfigs());
  }

  static String quickTimerId(String typeName) => '${typeName}_qt';

  /// "Save as workout" action of the quick timer pages.
  static Future<void> saveQuickTimer(
    BuildContext context,
    TimerBlock block,
  ) async {
    if (!block.isValid) {
      showElandSnack(context, ElandStrings.of('invalid_phase'));
      return;
    }
    final name = await showElandTextInputDialog(
      context: context,
      title: ElandStrings.of('save_as_workout'),
      label: ElandStrings.of('workout_name'),
      hint: ElandStrings.of('workout_name_hint'),
      initialValue: '${block.typeLabel} ${block.settingsLabel}',
      confirmText: ElandStrings.of('save_btn'),
      cancelText: ElandStrings.of('cancel_btn'),
    );
    if (name == null || !context.mounted) return;

    await ProviderScope.containerOf(context)
        .read(customWorkoutsProvider.notifier)
        .save(CustomWorkout.create(name: name, blocks: [block]));
    if (context.mounted) {
      showElandSnack(context, ElandStrings.of('workout_saved'));
    }
  }
}
