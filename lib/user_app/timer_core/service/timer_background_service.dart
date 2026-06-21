import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
class TimerBackgroundService {
  static const String channelId = 'eland_timer_channel';
  static const int notificationId = 101;

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        'ELAND Athletic Timer',
        description: 'Timer Notifications',
        importance: Importance.defaultImportance,
        playSound: false,
        enableVibration: false);

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
          onStart: TimerBackgroundService.onStart,
          autoStart: false,
          isForegroundMode: true,
          notificationChannelId: channelId,
          foregroundServiceNotificationId: notificationId),
      iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: onStart,
          onBackground: (service) => Future.value(true)),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    // --- Stati Interni ---
    Timer? ticker;
    bool isStopwatchMode = false;

    // Stato Workout
    List<dynamic> fullWorkoutQueue = [];
    int currentIntervalIndex = 0;
    DateTime? intervalStartTime;
    int? currentIntervalDuration;

    // Stato Stopwatch
    DateTime? stopwatchStartTime;
    List<int> lapTimes = [];

    // --- Logica di Sincronizzazione (Full Update) ---
    void sendFullStatus() {
      if (isStopwatchMode) {
        service.invoke('stopwatchUpdate', {
          'elapsedMilliseconds': stopwatchStartTime != null
              ? DateTime.now().difference(stopwatchStartTime!).inMilliseconds
              : 0,
          'laps': lapTimes,
          'status': 'running'
        });
      } else if (currentIntervalIndex < fullWorkoutQueue.length) {
        final interval = fullWorkoutQueue[currentIntervalIndex] as Map<String, dynamic>;
        final elapsed = DateTime.now().difference(intervalStartTime!).inSeconds;
        final remaining = (interval['duration'] as int) - elapsed;

        service.invoke('update', {
          'remainingSeconds': remaining > 0 ? remaining : 0,
          'intervalProgress': (interval['duration'] as int > 0) ? elapsed / (interval['duration'] as int) : 1.0,
          'title': interval['title'],
          'status': 'running'
        });
      }
    }

    // --- Motori di Calcolo ---
    void runInterval() {
      if (currentIntervalIndex >= fullWorkoutQueue.length) {
        service.invoke('update', {'status': 'completed'});
        return;
      }

      final interval = fullWorkoutQueue[currentIntervalIndex] as Map<String, dynamic>;
      currentIntervalDuration = interval['duration'] as int;
      intervalStartTime = DateTime.now();

      ticker?.cancel();
      ticker = Timer.periodic(const Duration(seconds: 1), (t) {
        sendFullStatus(); // Invio stato aggiornato
      });
    }

    void runStopwatch() {
      stopwatchStartTime = DateTime.now();
      ticker?.cancel();
      ticker = Timer.periodic(const Duration(milliseconds: 50), (t) {
        sendFullStatus(); // Invio stato alta frequenza
      });
    }

    // --- Listeners Comandi ---
    service.on('startFullWorkout').listen((event) {
      isStopwatchMode = false;
      fullWorkoutQueue = event?['queue'] as List<dynamic>? ?? [];
      currentIntervalIndex = 0;
      runInterval();
    });

    service.on('startStopwatch').listen((_) {
      isStopwatchMode = true;
      lapTimes = [];
      runStopwatch();
    });

    service.on('lapStopwatch').listen((_) {
      if (stopwatchStartTime != null) {
        final lap = DateTime.now().difference(stopwatchStartTime!).inMilliseconds;
        lapTimes.add(lap);
      }
    });

    service.on('requestStatus').listen((_) {
      sendFullStatus();
    });

    service.on('stop').listen((_) {
      ticker?.cancel();
      service.stopSelf();
    });

    print('[BS] Service Ready');
    service.invoke('serviceReady', {});
  }
}