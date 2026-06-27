import 'dart:async';

import 'package:eland_athletic/common/widgets/primary_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../strings.dart';
import '../../controllers/workout_controller.dart';
import '../../providers/timer_provider.dart';
import '../../models/timercore_enums.dart';
import '../../../widgets/phase_bar.dart';
import '../../models/timer_state.dart';
import '../../../widgets/eland_action_button.dart';
import '../../../widgets/eland_bottom_sheet.dart';
import '../../../widgets/eland_dialog.dart';
// Runners Widgets
import 'amrap_workout.dart';
import 'countdown_workout.dart';
import 'emom_workout.dart';
import 'fortime_workout.dart';
import 'rest_workout.dart';
import 'tabata_workout.dart';
import 'prepare_workout.dart';
import 'workout_complete.dart';

class WorkoutPage extends ConsumerStatefulWidget {
  const WorkoutPage({super.key});

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> {

  late ValueNotifier<int> _roundNotifier;

  @override
  void initState() {
    super.initState();
    _roundNotifier = ValueNotifier<int>(0);
  }

  @override
  void dispose() {
    _roundNotifier.dispose();
    TimerState.initial();
    super.dispose();
  }

  /// Dynamic loading of the workout body
  Widget _buildWorkoutSpecificBody(TimerState timerState) {
    if (timerState.status == TimerStatus.completed){
      return WorkoutCompleteWidget();
    }else{
      switch (timerState.timerType) {
        case TimerType.tabata:
          return TabataWorkoutWidget(timerState: timerState);
        case TimerType.emom:
          return EmomWorkoutWidget(timerState: timerState);
        case TimerType.fortime:
          return FortimeWorkoutWidget(timerState: timerState);
        case TimerType.rest:
          return RestWorkoutWidget(timerState: timerState);
        case TimerType.amrap:
          return AmrapWorkoutWidget(timerState: timerState, roundNotifier: _roundNotifier);
        case TimerType.countdown:
          return CountdownWorkoutWidget(timerState: timerState);
        case TimerType.preparation:
          return PrepareWorkoutWidget(timerState: timerState);
      }
    }
  }

  //Create the bottomSheet with the Notes and phase summaries
  void _openPhaseSummary(BuildContext context, TimerState timerState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ElandBottomSheet(
        initialChildSize: 0.6,
        builder: (scrollController) => ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: timerState.workoutPhaseSummary.length + 2, // +2 for notes and title
          itemBuilder: (context, index) {

            // -- Notes
            if (index == 0) {
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Workout title
                    Text(
                      ElandStrings.of('workout_phase_notes_title').toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Notes
                    Text(
                      (timerState.currentIntervalNotes?.isNotEmpty ?? false)
                          ? timerState.currentIntervalNotes!
                          : ElandStrings.of('no_notes_available'),
                      style: TextStyle(
                        color: (timerState.currentIntervalNotes?.isNotEmpty ?? false)
                            ? Theme.of(context).textTheme.headlineLarge!.color
                            : Theme.of(context).textTheme.bodyMedium!.color,
                        fontSize: 14,
                        fontStyle: (timerState.currentIntervalNotes?.isNotEmpty ?? false)
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            }

            // -- Workout Phase Title
            if (index == 1) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 8),
                child: Text(
                  ElandStrings.of('workout_phases_title').toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headlineLarge!.color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              );
            }

            // -- Phase list
            if(index >= 2) {
              return Column(
                children: [
                  if (index != 2)
                    Divider(
                        color: Theme.of(context).dividerColor),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // SX: phase number
                        Text(
                          "${ElandStrings.of('phase').toUpperCase()} ${index - 1}",
                          style: TextStyle(
                            color: (index - 1) == timerState.currentPhaseIndex ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color,
                            fontSize: (index - 1) == timerState.currentPhaseIndex ? 14 : 12,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // DX: phase name + settings
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                timerState.workoutPhaseSummary[index - 2].title.toUpperCase(),
                                style: TextStyle(
                                  color: (index - 1) == timerState.currentPhaseIndex ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: (index - 1) == timerState.currentPhaseIndex ? 14 : 12
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                timerState.workoutPhaseSummary[index - 2].details,
                                style: TextStyle(
                                  color: (index - 1) == timerState.currentPhaseIndex ? Theme.of(context).textTheme.headlineLarge!.color!.withAlpha(120) : Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(140),
                                  fontSize: (index - 1) == timerState.currentPhaseIndex ? 12 : 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  /// Ask to the user if it is sure to terminate the current workout
  void _stopWorkout(TimerState timerState){
    HapticFeedback.heavyImpact();

    if (timerState.status == TimerStatus.completed){
      _saveAndExit(timerState);
      return;
    }

    showElandDialog(
        context: context,
        title: ElandStrings.of('workout_abort_title').toUpperCase(),
        content: ElandStrings.of('workout_abort_desc'),
        cancelText: ElandStrings.of('cancel_btn').toUpperCase(),
        confirmText: ElandStrings.of('ok_btn').toUpperCase(),
        onResult: (confirmed) {
          if(confirmed){
            WorkoutController.instance.stopWorkout();
            Navigator.pop(context);
          }
        }
    );
  }

  //For now just exit... then save result in db
  void _saveAndExit(TimerState  timerState) {
    HapticFeedback.heavyImpact();
    WorkoutController.instance.stopWorkout();
    Navigator.pop(context);
  }

  /// Workout Page
  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _stopWorkout(timerState);
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,

          /// --- APP BAR ---
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => _stopWorkout(timerState),
            ),
            title: Text(
              timerState.workoutTitle.toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            centerTitle: true,
          ),

          /// --- BODY AREA ---
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        final curvedAnimation = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        );

                        return ScaleTransition(
                          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: _buildWorkoutSpecificBody(timerState),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// -- Bottom Navigation Bar
          bottomNavigationBar: Container(
            color: theme.scaffoldBackgroundColor,
            padding: const EdgeInsets.only(bottom: 20, top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 1, color: theme.dividerColor),
                const SizedBox(height: 20),
                timerState.status == TimerStatus.completed ?
                    PrimaryActionButton(height: 75, icon: Icons.waving_hand_rounded, label: ElandStrings.of('high_five').toUpperCase(), onPressed: () => _saveAndExit(timerState)) :
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElandActionButton(
                      icon: Icons.skip_next_rounded,
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        WorkoutController.instance.skipPhase();
                      },
                      iconColor: theme.textTheme.headlineLarge!.color,
                      size: 75,
                    ),
                    const SizedBox(width: 40),
                    ElandActionButton(
                      icon: timerState.status == TimerStatus.running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        timerState.status == TimerStatus.running
                            ? WorkoutController.instance.pauseWorkout()
                            : WorkoutController.instance.resumeWorkout();
                      },
                      iconColor: theme.colorScheme.primary,
                      size: 75,
                    ),
                    const SizedBox(width: 40),
                    ElandActionButton(
                      icon: Icons.close_rounded,
                      onPressed: () => _stopWorkout(timerState),
                      iconColor: theme.colorScheme.error,
                      size: 75,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                PhaseBar(
                  timerState: timerState,
                  onTap: () => _openPhaseSummary(context, timerState),
                ),
              ],
            ),
          ),
      )
    );
  }
}