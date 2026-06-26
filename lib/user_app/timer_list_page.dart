import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // --- APP BAR ---
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
          ElandStrings.of('card_timer_title').toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),

      // --- BODY ---
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  ElandStrings.of('timer_list_desc'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Timer List
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
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
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

              const SizedBox(height: 28),

              // --- Spacer
              Divider(
                height: 1,
                thickness: 1.2,
                indent: 40,
                endIndent: 40,
                color: theme.dividerColor,
              ),

              const SizedBox(height: 28),

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
              const SizedBox(height: 12),
              TimerRowItem(
                icon: Icons.shutter_speed_rounded,
                title: ElandStrings.of('timer_stopwatch').toUpperCase(),
                onTap: () {
                  HapticFeedback.lightImpact();
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