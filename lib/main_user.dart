import 'dart:ui';

import 'package:eland_athletic/common/timer_core/service/timer_background_service.dart';
import 'package:eland_athletic/common/timer_core/ui/workouts/stopwatch_page.dart';
import 'package:eland_athletic/common/timer_core/ui/workouts/workout_page.dart';
import 'package:eland_athletic/user_app/providers/settings_provider.dart';
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
import 'common/workouts/reminder_service.dart';
import 'common/workouts/workout_repository.dart';
import 'user_app/home_shell.dart';
import 'user_app/workouts/workout_detail_page.dart';

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

    onDidReceiveNotificationResponse: _handleNotificationResponse,
    // Live-notification buttons (pause/skip/stop) arrive on a background
    // isolate and are relayed to the timer service.
    onDidReceiveBackgroundNotificationResponse: timerNotificationActionHandler,
  );

  await TimerBackgroundService.initialize();
  await WorkoutRuntimeController.instance.initialize();
  _restoreReminders();

  // App opened by tapping a workout reminder while it was closed.
  final launchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  final launchResponse = launchDetails?.notificationResponse;
  if ((launchDetails?.didNotificationLaunchApp ?? false) &&
      launchResponse != null) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _handleNotificationResponse(launchResponse),
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const ElandUserApp(),
    ),
  );
}

/// Re-arms the weekly reminders (time zone change, app update, restore).
Future<void> _restoreReminders() async {
  try {
    await ReminderService.instance.initialize();
    final workouts = await WorkoutRepository().getWorkouts();
    await ReminderService.instance.rescheduleAll(workouts);
  } catch (e) {
    debugPrint('[ELAND] reminders restore failed: $e');
  }
}

void _handleNotificationResponse(NotificationResponse response) {
  final actionId = response.actionId;
  if (actionId != null && kTimerNotificationActions.contains(actionId)) {
    FlutterBackgroundService().invoke(actionId);
    return;
  }

  final payload = response.payload ?? '';
  final navigator = navigatorKey.currentState;
  if (navigator == null) return;

  if (payload.startsWith(ReminderService.payloadPrefix)) {
    final workoutId = payload.substring(ReminderService.payloadPrefix.length);
    navigator.popUntil((route) => route.isFirst);
    navigator.push(MaterialPageRoute(
      builder: (_) => WorkoutDetailPage(workoutId: workoutId),
    ));
    return;
  }

  final String? target = switch (payload) {
    'open_workout_page' => '/workout',
    'open_stopwatch_page' => '/stopwatch',
    _ => null,
  };
  if (target == null) return;

  // Go back to the running screen if it is already open, else open it.
  var found = false;
  navigator.popUntil((route) {
    if (route.settings.name == target) {
      found = true;
      return true;
    }
    return route.isFirst;
  });
  if (!found) navigator.pushNamed(target);
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
      home: ElandHomeShell(
        key: ValueKey(settings.language),
      ),
    );
  }
}
