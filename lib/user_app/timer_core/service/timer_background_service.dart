import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    final AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.setReleaseMode(ReleaseMode.stop);

    /// Enable Audio Ducking
    final AudioContext audioContext = AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.assistanceSonification,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
        options: {
          AVAudioSessionOptions.duckOthers,
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    );

    await AudioPlayer.global.setAudioContext(audioContext);

    // Timer State
    Timer? ticker;
    int remainingSeconds = 0;
    int elapsedSeconds = 0;
    int initialDuration = 0;
    bool isPaused = false;
    String direction = 'down';
    String title = '';
    String? notes;

    bool soundEnabled = true;
    bool hapticEnabled = true;

    Map<String, dynamic> currentAudioHapticConfig = {};

    /// Timer Audio & Haptic Feedback management
    void triggerHardwareFeedback(String phase) {
      final phaseConfig = currentAudioHapticConfig[phase] as Map<String, dynamic>?;
      if (phaseConfig == null) return;

      final String audioType = phaseConfig['audio'] as String? ?? 'none';
      final String hapticType = phaseConfig['haptic'] as String? ?? 'none';

      // 🛑 1. Riproduzione Audio Dinamica
      if (soundEnabled && audioType != 'none') {
        try {
          audioPlayer.play(AssetSource('audio/$audioType.m4a'));
        } catch (e) {
          debugPrint('Error on audio play ($phase): $e');
        }
      }

      // Haptic feedback
      if (hapticEnabled && hapticType != 'none'){
        Vibration.hasVibrator().then((hasVibrator) {
          switch (hapticType) {
            case 'single':
              Vibration.vibrate(duration: 150);
              break;
            case 'double':
              Vibration.vibrate(pattern: [0, 300, 150, 300]);
              break;
            case 'triple':
              Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 200]);
              break;
            case 'long':
              Vibration.vibrate(duration: 600);
              break;
          }
        });
      }
    }

    // --- LISTENING TO UI COMMANDS
    service.on('start').listen((event) async {
      if (event == null) return;

      final prefs = await SharedPreferences.getInstance();
      soundEnabled = prefs.getBool('soundEnabled') ?? true;
      hapticEnabled = prefs.getBool('hapticFeedback') ?? true;

      remainingSeconds = event['remainingSeconds'] as int? ?? 0;
      initialDuration = remainingSeconds;
      elapsedSeconds = event['elapsedSeconds'] as int? ?? 0;
      direction = event['direction'] as String? ?? 'down';
      title = event['title'] as String? ?? 'Workout';
      notes = event['notes'] as String?;
      isPaused = false;


      currentAudioHapticConfig = event['audioHapticConfig'] as Map<String, dynamic>? ?? {};

      ticker?.cancel();

      // Audio 1: Start Feedback
      triggerHardwareFeedback('start');

      ticker = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (isPaused) return;

        if (direction == 'down') {
          if (remainingSeconds > 0) {

            // Audio 4: 321 Countdown
            if (remainingSeconds <= 3) {
              triggerHardwareFeedback('countdown');
            }

            remainingSeconds--;
            elapsedSeconds++;

            // Audio 2: HalfTime Feedback
            if (remainingSeconds == (initialDuration ~/ 2) && initialDuration > 2) {
              triggerHardwareFeedback('half');
            }
            // Audio 3: Ten Seconds Feedback
            else if (remainingSeconds == 10 && initialDuration > 10) {
              triggerHardwareFeedback('tenSec');
            }

          } else {
            // Audio 5: End
            triggerHardwareFeedback('end');

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
      audioPlayer.dispose();
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