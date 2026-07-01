import 'package:eland_athletic/common/widgets/primary_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../eland_responsive.dart';
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

  Widget _buildWorkoutSpecificBody(TimerState timerState) {
    if (timerState.status == TimerStatus.completed) {
      return WorkoutCompleteWidget();
    }

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
        return AmrapWorkoutWidget(
          timerState: timerState,
          roundNotifier: _roundNotifier,
        );
      case TimerType.countdown:
        return CountdownWorkoutWidget(timerState: timerState);
      case TimerType.preparation:
        return PrepareWorkoutWidget(timerState: timerState);
    }
  }

  Widget _buildPhaseListView(
      BuildContext context,
      TimerState timerState,
      bool landscape, [
        ScrollController? scrollController,
      ]) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    return ListView.builder(
      controller: scrollController,
      padding: landscape
          ? EdgeInsets.only(
        right: r.spacing(30),
        top: r.spacing(20),
        bottom: r.spacing(20),
      )
          : EdgeInsets.symmetric(
        horizontal: r.pageHorizontalPadding,
        vertical: r.spacing(20),
      ),
      itemCount: timerState.workoutPhaseSummary.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            margin: EdgeInsets.only(bottom: r.spacing(20)),
            padding: EdgeInsets.all(r.spacing(16)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r.radius(12)),
              border: Border.all(color: theme.colorScheme.primary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ElandStrings.of('workout_phase_notes_title').toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: r.font(10),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: r.compactGap),
                Text(
                  (timerState.currentIntervalNotes?.isNotEmpty ?? false)
                      ? timerState.currentIntervalNotes!
                      : ElandStrings.of('no_notes_available'),
                  style: TextStyle(
                    fontSize: r.font(14),
                    color: theme.textTheme.bodyMedium?.color,
                    fontStyle:
                    (timerState.currentIntervalNotes?.isNotEmpty ?? false)
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }

        if (index == 1) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: r.spacing(16),
              top: r.compactGap,
            ),
            child: Text(
              ElandStrings.of('workout_phases_title').toUpperCase(),
              style: TextStyle(
                fontSize: r.font(14),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          );
        }

        final phaseIndex = index - 2;
        final phase = timerState.workoutPhaseSummary[phaseIndex];
        final isCurrent = phaseIndex == timerState.currentPhaseIndex - 1;

        return Column(
          children: [
            if (phaseIndex != 0) Divider(color: theme.dividerColor),
            Padding(
              padding: EdgeInsets.symmetric(vertical: r.spacing(5)),
              child: Row(
                children: [
                  Text(
                    "${ElandStrings.of('phase').toUpperCase()} ${phaseIndex + 1}",
                    style: TextStyle(
                      color: isCurrent
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium!.color,
                      fontWeight: FontWeight.w600,
                      fontSize: r.font(12),
                    ),
                  ),
                  SizedBox(width: r.spacing(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          phase.title.toUpperCase(),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: r.font(12),
                            color: isCurrent
                                ? theme.colorScheme.primary
                                : null,
                          ),
                        ),
                        Text(
                          phase.details,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: r.font(10),
                            color: theme.textTheme.bodyMedium!.color!
                                .withAlpha(140),
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
    final r = ElandResponsive(context);
    final isLandscape = r.isLandscape;

    final currentOrientation = MediaQuery.orientationOf(context);
    SystemChrome.setPreferredOrientations(
      currentOrientation == Orientation.landscape
          ? [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]
          : [DeviceOrientation.portraitUp],
    );

    if (isLandscape) {
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
              width: r.byWidth(
                0.45,
                min: 280,
                max: r.isDesktop ? 620 : 520,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(r.radius(16)),
                  bottomLeft: Radius.circular(r.radius(16)),
                ),
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 12) {
                    Navigator.of(context).pop();
                  }
                },
                child: SafeArea(
                  child: _buildPhaseListView(context, timerState, true),
                ),
              ),
            ),
          ),
        ),
        transitionBuilder: (context, anim1, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      ).then((_) => _setOrientations());
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => ElandBottomSheet(
          initialChildSize: 0.6,
          builder: (scrollController) =>
              _buildPhaseListView(context, timerState, false, scrollController),
        ),
      ).then((_) => _setOrientations());
    }
  }

  void _stopWorkout(TimerState timerState) {
    HapticFeedback.heavyImpact();

    if (timerState.status == TimerStatus.completed) {
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
        if (confirmed) {
          WorkoutController.instance.stopWorkout();
          Navigator.pop(context);
        }
      },
    );
  }

  void _saveAndExit(TimerState timerState) {
    HapticFeedback.heavyImpact();
    WorkoutController.instance.stopWorkout();
    Navigator.pop(context);
  }

  Widget _buildSideControls(TimerState timerState, ThemeData theme) {
    final r = ElandResponsive(context);

    final sidebarWidth = r.byWidth(
      0.22,
      min: 150,
      max: r.isDesktop ? 240 : 200,
    );

    final buttonSize = r.icon(
      75,
      minScale: 0.75,
      maxScale: 1.05,
    );

    final phaseBarWidth = r.spacing(
      70,
      minScale: 0.9,
      maxScale: 1.15,
    );

    return Container(
      width: sidebarWidth,
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
                  PrimaryActionButton(
                    height: r.byHeight(0.42, min: 160, max: 220),
                    width: 10,
                    icon: Icons.waving_hand_rounded,
                    label: "",
                    onPressed: () => _saveAndExit(timerState),
                  )
                else ...[
                  ElandActionButton(
                    icon: Icons.skip_next_rounded,
                    onPressed: () => WorkoutController.instance.skipPhase(),
                    size: buttonSize,
                  ),
                  SizedBox(height: r.settingsGap),
                  ElandActionButton(
                    icon: timerState.status == TimerStatus.running
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    onPressed: () => timerState.status == TimerStatus.running
                        ? WorkoutController.instance.pauseWorkout()
                        : WorkoutController.instance.resumeWorkout(),
                    iconColor: theme.colorScheme.primary,
                    size: buttonSize,
                  ),
                  SizedBox(height: r.settingsGap),
                  ElandActionButton(
                    icon: Icons.close_rounded,
                    onPressed: () => _stopWorkout(timerState),
                    iconColor: Colors.redAccent,
                    size: buttonSize,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            width: phaseBarWidth,
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

  Widget _buildTimer(TimerState timerState, ThemeData theme) {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          );

          return ScaleTransition(
            scale: Tween(begin: 0.9, end: 1.0).animate(curved),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: _buildWorkoutSpecificBody(timerState),
      ),
    );
  }

  Widget _buildBottomBar(TimerState timerState, ThemeData theme) {
    final r = ElandResponsive(context);

    final actionSize = r.icon(
      75,
      minScale: 0.88,
      maxScale: 1.05,
    );

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: EdgeInsets.only(
        bottom: r.safeBottom + r.spacing(12),
        top: r.spacing(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: theme.dividerColor),
          SizedBox(height: r.spacing(20)),

          timerState.status == TimerStatus.completed
              ? PrimaryActionButton(
            height: r.byHeight(0.09, min: 68, max: 78),
            icon: Icons.waving_hand_rounded,
            label: ElandStrings.of('high_five').toUpperCase(),
            onPressed: () => _saveAndExit(timerState),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElandActionButton(
                icon: Icons.skip_next_rounded,
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  WorkoutController.instance.skipPhase();
                },
                iconColor: theme.textTheme.headlineLarge!.color,
                size: actionSize,
              ),
              SizedBox(width: r.spacing(40)),
              ElandActionButton(
                icon: timerState.status == TimerStatus.running
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  timerState.status == TimerStatus.running
                      ? WorkoutController.instance.pauseWorkout()
                      : WorkoutController.instance.resumeWorkout();
                },
                iconColor: theme.colorScheme.primary,
                size: actionSize,
              ),
              SizedBox(width: r.spacing(40)),
              ElandActionButton(
                icon: Icons.close_rounded,
                onPressed: () => _stopWorkout(timerState),
                iconColor: Colors.redAccent,
                size: actionSize,
              ),
            ],
          ),

          SizedBox(height: r.spacing(20)),

          PhaseBar(
            timerState: timerState,
            onTap: () => _openPhaseSummary(context, timerState),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(TimerState timerState, ThemeData theme) {
    final r = ElandResponsive(context);

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
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
          fontSize: r.font(18),
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

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

        appBar: r.isLandscape ? null : _buildAppBar(timerState, theme),

        body: SafeArea(
          child: r.isLandscape
              ? Row(
            children: [
              Expanded(
                child: _buildTimer(timerState, theme),
              ),
              _buildSideControls(timerState, theme),
            ],
          )
              : Column(
            children: [
              Expanded(
                child: _buildTimer(timerState, theme),
              ),
            ],
          ),
        ),

        bottomNavigationBar:
        r.isLandscape ? null : _buildBottomBar(timerState, theme),
      ),
    );
  }
}