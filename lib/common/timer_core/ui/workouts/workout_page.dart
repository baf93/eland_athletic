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
import 'loading_workout.dart';

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

   _setOrientations();
  }


  @override
  void dispose() {
    _roundNotifier.dispose();
    TimerState.initial();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
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

  Widget _buildPhaseListView(BuildContext context, TimerState timerState, bool landscape, [ScrollController? scrollController]) {
    return ListView.builder(
      controller: scrollController,
      padding: landscape ? const EdgeInsets.only(right: 30, top: 20, bottom: 20)  : const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: timerState.workoutPhaseSummary.length + 2,
      itemBuilder: (context, index) {
        // -- Notes section
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
                Text(ElandStrings.of('workout_phase_notes_title').toUpperCase(),
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text(
                  (timerState.currentIntervalNotes?.isNotEmpty ?? false) ? timerState.currentIntervalNotes! : ElandStrings.of('no_notes_available'),
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: (timerState.currentIntervalNotes?.isNotEmpty ?? false) ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }

        // -- Title section (Index 1)
        if (index == 1) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 8),
            child: Text(ElandStrings.of('workout_phases_title').toUpperCase(),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          );
        }

        // -- Phase list (Index 2+)
        final phaseIndex = index - 2;
        final phase = timerState.workoutPhaseSummary[phaseIndex];
        final isCurrent = phaseIndex == timerState.currentPhaseIndex -1;

        return Column(
          children: [
            if (phaseIndex != 0) Divider(color: Theme.of(context).dividerColor),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${ElandStrings.of('phase').toUpperCase()} ${phaseIndex + 1}",
                      style: TextStyle(
                          color: isCurrent ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium!.color,
                          fontWeight: FontWeight.w600, fontSize: 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(phase.title.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isCurrent ? Theme.of(context).colorScheme.primary : null)),
                        Text(phase.details,
                            style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(140))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _setOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _openPhaseSummary(BuildContext context, TimerState timerState) {
    final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;

    final currentOrientation = MediaQuery.orientationOf(context);
    SystemChrome.setPreferredOrientations(currentOrientation == Orientation.landscape
        ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
        : [DeviceOrientation.portraitUp]);

    if (isLandscape) {
      // SIDE SHEET
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: "SideSummary",
        barrierColor: Colors.black.withAlpha(80),
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, _, __) => Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.45,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                border: Border(
                  left: BorderSide(color: Theme.of(context).dividerColor, width: 1),
                ),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
                    Navigator.of(context).pop();
                  }
                },
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    Expanded(
                      child: SafeArea(
                        child: _buildPhaseListView(context, timerState, true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ).then((_){
        _setOrientations();
      });
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => ElandBottomSheet(
          initialChildSize: 0.6,
          builder: (scrollController) => _buildPhaseListView(context, timerState, false, scrollController),
        ),
      ).then((_){
        _setOrientations();
      });
    }
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

  /// Widget section for Landscape / Portrait mode
  /// Side controls for landscape
  Widget _buildSideControls(TimerState timerState, ThemeData theme) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: theme.dividerColor)),
        color: theme.scaffoldBackgroundColor,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (timerState.status == TimerStatus.completed)
                  PrimaryActionButton(height: 280, width: 10, icon: Icons.waving_hand_rounded, label: "", onPressed: () => _saveAndExit(timerState))
                else ...[
                  ElandActionButton(
                    icon: Icons.skip_next_rounded,
                    onPressed: () => WorkoutController.instance.skipPhase(),
                    size: 75,
                  ),
                  const SizedBox(height: 20),
                  ElandActionButton(
                    icon: timerState.status == TimerStatus.running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    onPressed: () => timerState.status == TimerStatus.running ? WorkoutController.instance.pauseWorkout() : WorkoutController.instance.resumeWorkout(),
                    iconColor: theme.colorScheme.primary,
                    size: 75,
                  ),
                  const SizedBox(height: 20),
                  ElandActionButton(
                    icon: Icons.close_rounded,
                    onPressed: () => _stopWorkout(timerState),
                    iconColor: Colors.redAccent,
                    size: 75,
                  ),
                ],
              ],
            ),
          ),

          SizedBox(
            width: 80,
            child: RotatedBox(
              quarterTurns: 3,
              child: PhaseBar(
                timerState: timerState,
                onTap: () => _openPhaseSummary(context, timerState),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build timer section dinamically
  Widget _buildTimer(TimerState timerState, ThemeData theme){
      return Expanded(
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
      );
  }


  /// BottomBar only for portrait mode
  Widget _buildBottomBar(TimerState timerState, ThemeData theme){
    return Container(
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
                iconColor: Colors.redAccent,
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
    );
  }


  //Appbar visible only in landscape
  AppBar _buildAppBar(TimerState timerState, ThemeData theme){
    return AppBar(
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
    );
  }

  /// Workout Page
  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final theme = Theme.of(context);

    final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;

    if (timerState.isLoading) {
      return const WorkoutLoadingPage();
    }

    return PopScope(
      canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _stopWorkout(timerState);
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,

          /// --- APP BAR ---
          appBar: isLandscape ? null : _buildAppBar(timerState, theme),

          /// --- BODY AREA ---
          body: SafeArea(
            child: isLandscape ?
            Row(
              children: [
                _buildTimer(timerState, theme),
                _buildSideControls(timerState, theme),
              ],
            ) :
            Column(
              children: [
                _buildTimer(timerState, theme),
              ],
            ),
          ),

          /// -- Bottom Navigation Bar
          bottomNavigationBar: isLandscape ? null : _buildBottomBar(timerState, theme)
      )
    );
  }
}