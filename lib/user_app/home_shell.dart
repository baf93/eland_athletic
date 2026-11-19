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
import '../common/widgets/timer_row_item.dart';
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

  // Bumped on every visit to History so it reopens on today.
  int _historyVisit = 0;

  void _select(int index) {
    if (index == _index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _index = index;
      if (index == 2) _historyVisit++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          children: [
            const _TimersTab(),
            const MyWorkoutsPage(embedded: true),
            HistoryPage(key: ValueKey(_historyVisit), embedded: true),
          ],
        ),
        bottomNavigationBar: _ElandNavBar(
          index: _index,
          onSelect: _select,
          items: [
            _NavItem(
              Icons.timer_outlined,
              Icons.timer_rounded,
              ElandStrings.of('nav_timers'),
            ),
            _NavItem(
              Icons.format_list_bulleted_rounded,
              Icons.format_list_bulleted_rounded,
              ElandStrings.of('nav_workouts'),
            ),
            _NavItem(
              Icons.history_rounded,
              Icons.history_rounded,
              ElandStrings.of('nav_history'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem(this.icon, this.selectedIcon, this.label);
}

/// Minimal black tab bar: the active tab shows its name inside an orange
/// outline, the others are plain grey icons.
class _ElandNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  final List<_NavItem> items;

  const _ElandNavBar({
    required this.index,
    required this.onSelect,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final border =
        theme.extension<ElandCustomColors>()?.cardBorder ?? theme.dividerColor;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 0.6)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (var i = 0; i < items.length; i++)
                  Semantics(
                    label: items[i].label,
                    selected: i == index,
                    button: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelect(i),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          padding: EdgeInsets.symmetric(
                            horizontal: i == index ? 14 : 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: i == index ? border : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                i == index
                                    ? items[i].selectedIcon
                                    : items[i].icon,
                                size: i == index ? 20 : 24,
                                color: i == index ? primary : muted,
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                child: i == index
                                    ? Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Text(
                                          items[i].label.toUpperCase(),
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 11,
                                            letterSpacing: 1.2,
                                            fontWeight: FontWeight.w800,
                                            color: theme
                                                .textTheme
                                                .headlineLarge
                                                ?.color,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

/// Quick timers in the original Eland style: centred brand, motto and
/// full-width rows, grouped into interval timers and simple timers.
class _TimersTab extends StatelessWidget {
  const _TimersTab();

  static final _intervals = <_TimerKind>[
    _TimerKind(
      Icons.fitness_center_rounded,
      'timer_tabata',
      (_) => const TabataSettingsPage(),
    ),
    _TimerKind(
      Icons.loop_rounded,
      'timer_emom',
      (_) => const EMOMSettingsPage(),
    ),
    _TimerKind(
      Icons.all_inclusive_rounded,
      'timer_amrap',
      (_) => const AmrapSettingsPage(),
    ),
    _TimerKind(
      Icons.flag_rounded,
      'timer_fortime',
      (_) => const FortimeSettingsPage(),
    ),
  ];

  static final _simple = <_TimerKind>[
    _TimerKind(
      Icons.hourglass_bottom_rounded,
      'timer_countdown',
      (_) => const CountdownSettingsPage(),
    ),
    // Stopwatch: started on open, page has its own route name.
    const _TimerKind(Icons.shutter_speed_rounded, 'timer_stopwatch', null),
  ];

  void _open(BuildContext context, _TimerKind kind) {
    final page = kind.page;
    if (page == null) {
      StopwatchController.instance.launchStopwatch();
      Navigator.of(context).push(
        MaterialPageRoute(
          settings: const RouteSettings(name: '/stopwatch'),
          builder: (_) => const StopwatchPage(),
        ),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    Widget rows(List<_TimerKind> kinds) => Column(
      children: [
        for (var i = 0; i < kinds.length; i++) ...[
          if (i > 0) SizedBox(height: r.cardGap),
          TimerRowItem(
            icon: kinds[i].icon,
            title: ElandStrings.of(kinds[i].labelKey).toUpperCase(),
            onTap: () => _open(context, kinds[i]),
          ),
        ],
      ],
    );

    Widget divider() => Padding(
      padding: EdgeInsets.symmetric(vertical: r.spacing(22)),
      child: Divider(
        height: 1,
        thickness: 1.2,
        indent: r.spacing(40),
        endIndent: r.spacing(40),
        color: theme.dividerColor,
      ),
    );

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          r.pageHorizontalPadding,
          r.spacing(8),
          r.pageHorizontalPadding,
          r.spacing(24),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.settings, size: r.icon(26)),
                    tooltip: ElandStrings.of('nav_settings'),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'ELAND',
                    style: TextStyle(
                      fontSize: r.font(54, maxScale: 1.08),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      height: 1.05,
                      color: theme.textTheme.headlineLarge?.color,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'ATHLETIC',
                    style: TextStyle(
                      fontSize: r.font(18),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 5,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: r.spacing(12)),
                Text(
                  ElandStrings.of('app_motto'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: r.font(14),
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.2,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                SizedBox(height: r.spacing(32)),
                rows(_intervals),
                divider(),
                rows(_simple),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
