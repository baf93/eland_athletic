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

class FortimeSettingsPage extends StatefulWidget {
  const FortimeSettingsPage({super.key});

  @override
  State<FortimeSettingsPage> createState() => _FortimeSettingsPageState();
}

class _FortimeSettingsPageState extends State<FortimeSettingsPage> {
  int _totalMinutes = 10;
  int _totalSeconds = 0;

  TimerBlock get _block => TimerBlock(
        type: TimerType.fortime,
        params: {'minutes': _totalMinutes, 'seconds': _totalSeconds},
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
          ElandStrings.of('timer_fortime').toUpperCase(),
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
                            label: ElandStrings.of('time_cap_min'),
                            value: _totalMinutes,
                            min: 0,
                            onChanged: (newValue) =>
                                setState(() => _totalMinutes = newValue),
                          ),
                          SizedBox(height: r.settingsGap),
                          TimerSettingSelector(
                            label: ElandStrings.of('time_cap_sec'),
                            value: _totalSeconds,
                            min: 0,
                            max: 59,
                            onChanged: (newValue) =>
                                setState(() => _totalSeconds = newValue),
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