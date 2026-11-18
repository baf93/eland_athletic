import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../common/eland_responsive.dart';
import '../common/strings.dart';
import '../common/theme.dart';
import '../common/timer_core/controllers/stopwatch_controller.dart';
import '../common/timer_core/ui/settings/amrap_settings_page.dart';
import '../common/timer_core/ui/settings/countdown_settings_page.dart';
import '../common/timer_core/ui/settings/emom_settings_page.dart';
import '../common/timer_core/ui/settings/fortime_settings_page.dart';
import '../common/timer_core/ui/settings/tabata_settings_page.dart';
import '../common/timer_core/ui/workouts/stopwatch_page.dart';
import 'settings_page.dart';
import 'workouts/history_page.dart';
import 'workouts/my_workouts_page.dart';

/// Root of the user app: four tabs with a bottom navigation bar.
class ElandHomeShell extends StatefulWidget {
  const ElandHomeShell({super.key});

  @override
  State<ElandHomeShell> createState() => _ElandHomeShellState();
}

class _ElandHomeShellState extends State<ElandHomeShell>
    with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      FlutterBackgroundService().invoke('stop');
    }
  }

  void _select(int index) {
    if (index == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.textTheme.bodyMedium?.color;

    return PopScope(
      // Back from another tab goes to the timers first, then leaves the app.
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _index = 0);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: IndexedStack(
          index: _index,
          children: const [
            _TimersTab(),
            MyWorkoutsPage(embedded: true),
            HistoryPage(embedded: true),
            SettingsPage(embedded: true),
          ],
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.dividerColor)),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: theme.scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              indicatorColor: primary.withAlpha(40),
              height: 64,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              iconTheme: WidgetStateProperty.resolveWith(
                (states) => IconThemeData(
                  color: states.contains(WidgetState.selected) ? primary : muted,
                ),
              ),
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.6,
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: states.contains(WidgetState.selected) ? primary : muted,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _select,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.timer_outlined),
                  selectedIcon: const Icon(Icons.timer_rounded),
                  label: ElandStrings.of('nav_timers'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.playlist_play_rounded),
                  label: ElandStrings.of('nav_workouts'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.history_rounded),
                  label: ElandStrings.of('nav_history'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings_rounded),
                  label: ElandStrings.of('nav_settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerKind {
  final IconData icon;
  final String labelKey;
  final WidgetBuilder? page;

  const _TimerKind(this.icon, this.labelKey, this.page);
}

/// Quick timers: compact brand header and a 2-column grid.
class _TimersTab extends StatelessWidget {
  const _TimersTab();

  static final _kinds = <_TimerKind>[
    _TimerKind(Icons.fitness_center_rounded, 'timer_tabata',
        (_) => const TabataSettingsPage()),
    _TimerKind(Icons.loop_rounded, 'timer_emom', (_) => const EMOMSettingsPage()),
    _TimerKind(Icons.all_inclusive_rounded, 'timer_amrap',
        (_) => const AmrapSettingsPage()),
    _TimerKind(Icons.flag_rounded, 'timer_fortime',
        (_) => const FortimeSettingsPage()),
    _TimerKind(Icons.hourglass_bottom_rounded, 'timer_countdown',
        (_) => const CountdownSettingsPage()),
    // Stopwatch: started on open, page has its own route name.
    const _TimerKind(Icons.shutter_speed_rounded, 'timer_stopwatch', null),
  ];

  void _open(BuildContext context, _TimerKind kind) {
    final page = kind.page;
    if (page == null) {
      StopwatchController.instance.launchStopwatch();
      Navigator.of(context).push(MaterialPageRoute(
        settings: const RouteSettings(name: '/stopwatch'),
        builder: (_) => const StopwatchPage(),
      ));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  r.pageHorizontalPadding,
                  r.spacing(28),
                  r.pageHorizontalPadding,
                  r.spacing(8),
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ELAND',
                        style: TextStyle(
                          fontSize: r.font(34, maxScale: 1.08),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          height: 1,
                          color: theme.textTheme.headlineLarge?.color,
                        ),
                      ),
                      SizedBox(height: r.spacing(6)),
                      Text(
                        'ATHLETIC',
                        style: TextStyle(
                          fontSize: r.font(12),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: r.spacing(28)),
                      Text(
                        ElandStrings.of('quick_timers').toUpperCase(),
                        style: TextStyle(
                          fontSize: r.font(12),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  r.pageHorizontalPadding,
                  r.spacing(8),
                  r.pageHorizontalPadding,
                  r.spacing(24),
                ),
                sliver: SliverGrid.builder(
                  itemCount: _kinds.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: r.cardGap,
                    crossAxisSpacing: r.cardGap,
                    childAspectRatio: 1.25,
                  ),
                  itemBuilder: (context, i) => _TimerTile(
                    kind: _kinds[i],
                    onTap: () => _open(context, _kinds[i]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerTile extends StatelessWidget {
  final _TimerKind kind;
  final VoidCallback onTap;

  const _TimerTile({required this.kind, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);
    final border = theme.extension<ElandCustomColors>()?.cardBorder ??
        theme.dividerColor;
    final radius = BorderRadius.circular(r.radius(18));

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: border, width: 1.2),
          ),
          padding: EdgeInsets.all(r.spacing(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(kind.icon,
                  size: r.icon(28), color: theme.colorScheme.primary),
              Text(
                ElandStrings.of(kind.labelKey).toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: r.font(15),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
