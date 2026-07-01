import 'package:eland_athletic/common/timer_core/controllers/stopwatch_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/eland_responsive.dart';
import '../common/strings.dart';
import '../common/widgets/timer_row_item.dart';
import '../common/timer_core/ui/settings/emom_settings_page.dart';
import '../common/timer_core/ui/workouts/stopwatch_page.dart';
import '../common/timer_core/ui/settings/tabata_settings_page.dart';
import '../common/timer_core/ui/settings/amrap_settings_page.dart';
import '../common/timer_core/ui/settings/fortime_settings_page.dart';
import '../common/timer_core/ui/settings/countdown_settings_page.dart';

class TimerListPage extends StatelessWidget {
  const TimerListPage({super.key});

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
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            ElandStrings.of('card_timer_title').toUpperCase(),
            style: TextStyle(
              fontSize: r.font(18),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: r.spacing(16),
            vertical: r.spacing(30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: r.adaptive(500, 560, 620),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.spacing(20),
                    ),
                    child: Text(
                      ElandStrings.of('timer_list_desc'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: r.font(16),
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: r.spacing(32)),

              TimerRowItem(
                icon: Icons.fitness_center_rounded,
                title: ElandStrings.of('timer_tabata').toUpperCase(),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TabataSettingsPage(),
                    ),
                  );
                },
              ),
              SizedBox(height: r.cardGap),

              TimerRowItem(
                icon: Icons.loop_rounded,
                title: ElandStrings.of('timer_emom').toUpperCase(),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EMOMSettingsPage(),
                    ),
                  );
                },
              ),
              SizedBox(height: r.cardGap),

              TimerRowItem(
                icon: Icons.all_inclusive_rounded,
                title: ElandStrings.of('timer_amrap').toUpperCase(),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AmrapSettingsPage(),
                    ),
                  );
                },
              ),
              SizedBox(height: r.cardGap),

              TimerRowItem(
                icon: Icons.timer_10_outlined,
                title: ElandStrings.of('timer_fortime').toUpperCase(),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FortimeSettingsPage(),
                    ),
                  );
                },
              ),

              SizedBox(height: r.spacing(28)),

              Divider(
                height: 1,
                thickness: 1.2,
                indent: r.spacing(40),
                endIndent: r.spacing(40),
                color: theme.dividerColor,
              ),

              SizedBox(height: r.spacing(28)),

              TimerRowItem(
                icon: Icons.hourglass_bottom_rounded,
                title: ElandStrings.of('timer_countdown').toUpperCase(),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CountdownSettingsPage(),
                    ),
                  );
                },
              ),
              SizedBox(height: r.cardGap),

              TimerRowItem(
                icon: Icons.shutter_speed_rounded,
                title: ElandStrings.of('timer_stopwatch').toUpperCase(),
                onTap: () {
                  HapticFeedback.lightImpact();
                  StopwatchController.instance.launchStopwatch();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const StopwatchPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}