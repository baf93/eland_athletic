import 'dart:ui';
import 'package:eland_athletic/common/timer_core/ui/workouts/stopwatch_page.dart';
import 'package:eland_athletic/user_app/timer_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'common/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'user_app/focus_page.dart';
import 'user_app/nutri_page.dart';
import 'user_app/pt_page.dart';
import 'common/strings.dart';
import 'user_app/providers/settings_provider.dart';
import 'common/timer_core/service/timer_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'common/timer_core/ui/workouts/workout_page.dart';
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final notificationStatus = await Permission.notification.status;
  if (notificationStatus.isDenied) Permission.notification.request();

  final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  final String savedLanguage = sharedPrefs.getString('language') ?? PlatformDispatcher.instance.locale.languageCode;
  ElandStrings.initLocale(savedLanguage);

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.initialize(
    settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/launcher_icon')),
    onDidReceiveNotificationResponse: (response) {
      List<String> routesToPush = [];
      if (response.payload == 'open_workout_page') {
        routesToPush = ['/', '/timer_list', '/workout'];
      }else{
        routesToPush = ['/', '/timer_list', '/stopwatch'];
      }
      navigatorKey.currentState?.popUntil((route) => false);
      for (var routeName in routesToPush) {
        navigatorKey.currentState?.pushNamed(routeName);
      }
    },
  );

  await TimerBackgroundService.initialize();

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

    final selectedColor = ElandColors.customPalette[settings.primaryColorIndex];
    final lightColorScheme = ColorScheme.light(primary: selectedColor);
    final darkColorScheme = ColorScheme.dark(primary: selectedColor);

    final lightTheme = ElandTheme.lightTheme.copyWith(colorScheme: lightColorScheme);
    final darkTheme = ElandTheme.darkTheme.copyWith(colorScheme: darkColorScheme);

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
      home: UserDashboard(key: ValueKey(settings.language)),
    );
  }
}

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final List<Widget> _pages = const [FocusPage(), NutriPage(), PtPage()];

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
    final elandColors = Theme.of(context).extension<ElandCustomColors>()!;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: elandColors.cardBorder!, width: 1)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              HapticFeedback.lightImpact();
              setState(() => _currentIndex = index);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: elandColors.unselectedItems,
            selectedFontSize: 14,
            unselectedFontSize: 11,
            iconSize: 24,
            elevation: 0,
            items: [
              BottomNavigationBarItem(icon: const Padding(padding: EdgeInsets.only(top: 4, bottom: 4), child: Icon(Icons.bolt_rounded)), label: ElandStrings.of('tab_focus')),
              BottomNavigationBarItem(icon: const Padding(padding: EdgeInsets.only(top: 4, bottom: 4), child: Icon(Icons.set_meal_rounded)), label: ElandStrings.of('tab_nutri')),
              BottomNavigationBarItem(icon: const Padding(padding: EdgeInsets.only(top: 4, bottom: 4), child: Icon(Icons.fitness_center_rounded)), label: ElandStrings.of('tab_pt')),
            ],
          ),
        ),
      ),
    );
  }
}