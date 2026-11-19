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

class TabataSettingsPage extends StatefulWidget {
  const TabataSettingsPage({super.key});

  @override
  State<TabataSettingsPage> createState() => _TabataSettingsPageState();
}

class _TabataSettingsPageState extends State<TabataSettingsPage> {
  int _workTime = 20;
  int _restTime = 10;
  int _roundSet = 8;
  int _setNumber = 3;
  int _restBetweenSet = 60;

  String get _totalWorkoutTime =>
      TimerBlock.formatDuration(_block.totalSeconds);

  TimerBlock get _block => TimerBlock(
        type: TimerType.tabata,
        params: {'work': _workTime, 'rest': _restTime, 'rounds': _roundSet, 'sets': _setNumber, 'setRest': _restBetweenSet},
      );

  void _startWorkout() => WorkoutLauncher.launchQuickTimer(context, _block);

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
          ElandStrings.of('timer_tabata').toUpperCase(),
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
                text:
                '${ElandStrings.of('total_time').toUpperCase()}: $_totalWorkoutTime',
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
                            label: '${ElandStrings.of('work_time')} (s)',
                            min: 1,
                            value: _workTime,
                            onChanged: (v) => setState(() => _workTime = v),
                          ),
                          SizedBox(height: r.settingsGap),
                          TimerSettingSelector(
                            label: '${ElandStrings.of('rest_time')} (s)',
                            min: 1,
                            value: _restTime,
                            onChanged: (v) => setState(() => _restTime = v),
                          ),
                          SizedBox(height: r.settingsGap),
                          TimerSettingSelector(
                            label: ElandStrings.of('round_set'),
                            min: 1,
                            max: 20,
                            value: _roundSet,
                            onChanged: (v) => setState(() => _roundSet = v),
                          ),
                          SizedBox(height: r.settingsGap),
                          TimerSettingSelector(
                            label: ElandStrings.of('set_number'),
                            min: 1,
                            value: _setNumber,
                            onChanged: (v) => setState(() => _setNumber = v),
                          ),
                          SizedBox(height: r.settingsGap),
                          TimerSettingSelector(
                            label: '${ElandStrings.of('rest_between_set')} (s)',
                            min: 1,
                            value: _restBetweenSet,
                            onChanged: (v) =>
                                setState(() => _restBetweenSet = v),
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