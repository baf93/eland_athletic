import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TimerBackgroundService {
  static const String channelId = 'eland_timer_channel';
  static const int notificationId = 101;

  /// Service Configuration
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      'ELAND Athletic Timer',
      description: 'Timer Notifications',
      importance: Importance.max,
      playSound: false,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: channelId,
        initialNotificationTitle: 'ELAND',
        initialNotificationContent: '',
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: (service) => Future.value(true),
      ),
    );
  }

  /// Entry Point of the Timer Background Service
  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();

    // Timer State
    Timer? ticker;
    int remainingSeconds = 0;
    int elapsedSeconds = 0;
    bool isPaused = false;
    String direction = 'down';
    String title = '';
    String? notes;

    // --- LISTENING TO UI COMMANDS
    service.on('start').listen((event) {
      if (event == null) return;

      remainingSeconds = event['remainingSeconds'] as int? ?? 0;
      elapsedSeconds = event['elapsedSeconds'] as int? ?? 0;
      direction = event['direction'] as String? ?? 'down';
      title = event['title'] as String? ?? 'Workout';
      notes = event['notes'] as String?;
      isPaused = false;

      ticker?.cancel();
      ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (isPaused) return;

        if (direction == 'down') {
          if (remainingSeconds > 0) {
            remainingSeconds--;
            elapsedSeconds++;
          } else {
            // End of the current interval
            _sendStateUpdate(service, remainingSeconds, elapsedSeconds, 'completed', title, notes);
            timer.cancel();
            return;
          }
        } else {
          // Count Up (Stopwatch)
          elapsedSeconds++;
        }

        // Send constant updates to the UI
        _sendStateUpdate(service, remainingSeconds, elapsedSeconds, 'running', title, notes);

        // Update live system notification
        _updateNotification(
            localNotifications,
            title,
            _formatTime(direction == 'down' ? remainingSeconds : elapsedSeconds),
            notes
        );
      });
    });

    service.on('pause').listen((_) {
      isPaused = true;
      _sendStateUpdate(service, remainingSeconds, elapsedSeconds, 'paused', title, notes);
      _updateNotification(localNotifications, 'PAUSED - $title', _formatTime(direction == 'down' ? remainingSeconds : elapsedSeconds), notes);
    });

    service.on('resume').listen((_) {
      isPaused = false;
      _sendStateUpdate(service, remainingSeconds, elapsedSeconds, 'running', title, notes);
    });

    service.on('stop').listen((_) {
      ticker?.cancel();
      _sendStateUpdate(service, 0, 0, 'idle', '', null);
      service.stopSelf();
    });
  }

  /// Helper to format JSON packets sent to the UI
  static void _sendStateUpdate(
      ServiceInstance service,
      int remaining,
      int elapsed,
      String status,
      String title,
      String? notes,
      ) {
    service.invoke('update', {
      'remainingSeconds': remaining,
      'elapsedSeconds': elapsed,
      'status': status,
      'title': title,
      'notes': notes,
    });
  }

  /// Updates the persistent push notification (Foreground)
  static void _updateNotification(
      FlutterLocalNotificationsPlugin notifications,
      String title,
      String content,
      String? notes,
      ) {
    final summary = notes != null && notes.isNotEmpty ? '$content\n📌 $notes' : content;

    notifications.show(
      id: notificationId,
      title: title.toUpperCase(),
      body: summary,
      notificationDetails:  NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'ELAND Athletic Timer',
          ongoing: true,
          onlyAlertOnce: true,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: false,
        ),
      ),
    );
  }

  static String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}