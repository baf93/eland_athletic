import 'package:eland_athletic/common/timer_core/models/timer_block.dart';
import 'package:eland_athletic/common/workouts/workout_launcher.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../eland_responsive.dart';
import '../../../strings.dart';
import '../../../widgets/timer_setting_selector.dart';
import '../../../widgets/pill_badge.dart';
import '../../../widgets/primary_action_button.dart';

class EMOMSettingsPage extends StatefulWidget {
  const EMOMSettingsPage({super.key});

  @override
  State<EMOMSettingsPage> createState() => _EMOMSettingsPageState();
}

class _EMOMSettingsPageState extends State<EMOMSettingsPage> {
  int _totalMinutes = 10;
  int _roundDuration = 60;

  TimerBlock get _block => TimerBlock(
        type: TimerType.emom,
        params: {'roundSeconds': _roundDuration, 'rounds': _totalMinutes},
      );

  void _startWorkout() => WorkoutLauncher.launchQuickTimer(context, _block);

  String get _totalWorkoutTime =>
      TimerBlock.formatDuration(_block.totalSeconds);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.maybePop(context);
          },
        ),
        title: Text(
          ElandStrings.of('timer_emom').toUpperCase(),
          style: TextStyle(
            fontSize: r.font(18),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: ElandStrings.of('save_as_workout'),
            onPressed: () => WorkoutLauncher.saveQuickTimer(context, _block),
          ),
        ],
        centerTitle: true,
      ),

      body: SafeArea(
        child: Padding(
          padding: r.pagePadding,
          child: Column(
            children: [
              PillBadge(
                text: '${ElandStrings.of('total_time').toUpperCase()}: $_totalWorkoutTime',
              ),

              SizedBox(height: r.compactGap),

              Expanded(
                child: CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TimerSettingSelector(
                            label: '${ElandStrings.of('round_duration')} (s)',
                            value: _roundDuration,
                            onChanged: (newValue) =>
                                setState(() => _roundDuration = newValue),
                          ),
                          SizedBox(height: r.settingsGap),
                          TimerSettingSelector(
                            label: ElandStrings.of('rounds_label'),
                            value: _totalMinutes,
                            min: 1,
                            max: 60,
                            onChanged: (newValue) =>
                                setState(() => _totalMinutes = newValue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: r.bottomButtonPadding,
                child: PrimaryActionButton(
                  height: r.primaryButtonHeight,
                  label: ElandStrings.of('start_btn'),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _startWorkout();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}