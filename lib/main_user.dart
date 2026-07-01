import 'dart:ui';

import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:eland_athletic/common/timer_core/controllers/stopwatch_controller.dart';
import 'package:eland_athletic/common/timer_core/service/timer_background_service.dart';
import 'package:eland_athletic/common/timer_core/ui/settings/amrap_settings_page.dart';
import 'package:eland_athletic/common/timer_core/ui/settings/countdown_settings_page.dart';
import 'package:eland_athletic/common/timer_core/ui/settings/emom_settings_page.dart';
import 'package:eland_athletic/common/timer_core/ui/settings/fortime_settings_page.dart';
import 'package:eland_athletic/common/timer_core/ui/settings/tabata_settings_page.dart';
import 'package:eland_athletic/common/timer_core/ui/workouts/stopwatch_page.dart';
import 'package:eland_athletic/common/timer_core/ui/workouts/workout_page.dart';
import 'package:eland_athletic/common/widgets/timer_row_item.dart';
import 'package:eland_athletic/user_app/providers/settings_provider.dart';
import 'package:eland_athletic/user_app/settings_page.dart';
import 'package:eland_athletic/user_app/timer_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'common/timer_core/runtime/workout_runtime_controller.dart';

import 'common/strings.dart';
import 'common/theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final notificationStatus = await Permission.notification.status;
  if (notificationStatus.isDenied) {
    Permission.notification.request();
  }

  final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

  final String savedLanguage =
      sharedPrefs.getString('language') ??
          PlatformDispatcher.instance.locale.languageCode;

  ElandStrings.initLocale(savedLanguage);

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.initialize(

    settings: InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    ),

    onDidReceiveNotificationResponse: (response) {
      List<String> routesToPush = [];

      if (response.payload == 'open_workout_page') {
        routesToPush = ['/', '/timer_list', '/workout'];
      } else {
        routesToPush = ['/', '/timer_list', '/stopwatch'];
      }

      navigatorKey.currentState?.popUntil((route) => false);

      for (final routeName in routesToPush) {
        navigatorKey.currentState?.pushNamed(routeName);
      }
    },
  );

  await TimerBackgroundService.initialize();
  await WorkoutRuntimeController.instance.initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const ElandUserApp(),
    ),
  );
}

class ElandUserApp extends ConsumerWidget {
  const ElandUserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    WakelockPlus.toggle(enable: settings.keepScreenOn);
    ElandStrings.initLocale(settings.language);

    final selectedColor =
    ElandColors.customPalette[settings.primaryColorIndex];

    final lightColorScheme = ColorScheme.light(primary: selectedColor);
    final darkColorScheme = ColorScheme.dark(primary: selectedColor);

    final lightTheme = ElandTheme.lightTheme.copyWith(
      colorScheme: lightColorScheme,
    );

    final darkTheme = ElandTheme.darkTheme.copyWith(
      colorScheme: darkColorScheme,
    );

    return MaterialApp(
      title: ElandStrings.of('app_name_user'),
      navigatorKey: navigatorKey,
      routes: {
        '/timer_list': (context) => const TimerListPage(),
        '/workout': (context) => const WorkoutPage(),
        '/stopwatch': (context) => const StopwatchPage(),
      },
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: ElandV1HomePage(
        key: ValueKey(settings.language),
      ),
    );
  }
}

class ElandV1HomePage extends StatefulWidget {
  const ElandV1HomePage({super.key});

  @override
  State<ElandV1HomePage> createState() => _ElandV1HomePageState();
}

class _ElandV1HomePageState extends State<ElandV1HomePage>
    with WidgetsBindingObserver {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: r.pageHorizontalPadding,
            vertical: r.spacing(12),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.settings,
                          size: r.icon(26),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: r.compactGap),

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'ELAND',
                      style: TextStyle(
                        fontSize: r.font(54, maxScale: 1.08),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
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

                  SizedBox(height: r.spacing(26)),


                  TimerRowItem(
                    icon: Icons.fitness_center_rounded,
                    title: ElandStrings.of('timer_tabata').toUpperCase(),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TabataSettingsPage(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: r.cardGap),

                  TimerRowItem(
                    icon: Icons.loop_rounded,
                    title: ElandStrings.of('timer_emom').toUpperCase(),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EMOMSettingsPage(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: r.cardGap),

                  TimerRowItem(
                    icon: Icons.all_inclusive_rounded,
                    title: ElandStrings.of('timer_amrap').toUpperCase(),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AmrapSettingsPage(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: r.cardGap),

                  TimerRowItem(
                    icon: Icons.timer_10_outlined,
                    title: ElandStrings.of('timer_fortime').toUpperCase(),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FortimeSettingsPage(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: r.spacing(24)),

                  Divider(
                    height: 1,
                    thickness: 1.2,
                    indent: r.spacing(40),
                    endIndent: r.spacing(40),
                    color: theme.dividerColor,
                  ),

                  SizedBox(height: r.spacing(24)),

                  TimerRowItem(
                    icon: Icons.hourglass_bottom_rounded,
                    title: ElandStrings.of('timer_countdown').toUpperCase(),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CountdownSettingsPage(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: r.cardGap),

                  TimerRowItem(
                    icon: Icons.shutter_speed_rounded,
                    title: ElandStrings.of('timer_stopwatch').toUpperCase(),
                    onTap: () {
                      StopwatchController.instance.launchStopwatch();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const StopwatchPage(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: r.spacing(24)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}