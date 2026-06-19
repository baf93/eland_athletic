import 'package:flutter/material.dart';
import '../common/strings.dart';

class TimerListPage extends StatelessWidget {
  const TimerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          ElandStrings.of('card_timer_title').toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),

      // --- Body ---
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  ElandStrings.of('timer_list_desc'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153) ?? const Color(0xFF9E9E9E),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              _buildTimerRowItem(
                context: context,
                icon: Icons.fitness_center_rounded,
                title: ElandStrings.of('timer_tabata').toUpperCase(),
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildTimerRowItem(
                context: context,
                icon: Icons.loop_rounded,
                title: ElandStrings.of('timer_emom').toUpperCase(),
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildTimerRowItem(
                context: context,
                icon: Icons.all_inclusive_rounded,
                title: ElandStrings.of('timer_amrap').toUpperCase(),
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildTimerRowItem(
                context: context,
                icon: Icons.timer_10_outlined,
                title: ElandStrings.of('timer_fortime').toUpperCase(),
                onTap: () {},
              ),

              const SizedBox(height: 28),

              _buildTimerRowItem(
                context: context,
                icon: Icons.hourglass_bottom_rounded,
                title: ElandStrings.of('timer_countdown').toUpperCase(),
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildTimerRowItem(
                context: context,
                icon: Icons.shutter_speed_rounded,
                title: ElandStrings.of('timer_stopwatch').toUpperCase(),
                onTap: () {},
              ),

            ],
          ),
        ),
      ),
    );
  }
  //TODO: Move this widget as a common widget
  Widget _buildTimerRowItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: theme.dividerColor.withAlpha(50),
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          child: Row(
            children: [
              Icon(icon, size: 24, color: theme.colorScheme.primary),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.textTheme.bodyMedium?.color?.withAlpha(100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}