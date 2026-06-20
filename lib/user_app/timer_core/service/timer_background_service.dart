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

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      'ELAND Athletic Timer',
      description: 'Timer Notifications',
      importance: Importance.max,
      playSound: false,
    );

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
          foregroundServiceNotificationId: notificationId
      ),
      iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: onStart,
          onBackground: (service) => Future.value(true)
      ),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    debugPrint(" *** QUI SERVICE");
    DartPluginRegistrant.ensureInitialized();
    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
    final AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.setReleaseMode(ReleaseMode.stop);

    final AudioContext audioContext = AudioContext(
      android: AudioContextAndroid(isSpeakerphoneOn: true, stayAwake: true, contentType: AndroidContentType.sonification, usageType: AndroidUsageType.assistanceSonification, audioFocus: AndroidAudioFocus.gainTransientMayDuck),
      iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient, options: {AVAudioSessionOptions.duckOthers, AVAudioSessionOptions.mixWithOthers}),
    );
    await AudioPlayer.global.setAudioContext(audioContext);

    // --- Stato Interno ---
    Timer? ticker;
    List<dynamic> fullWorkoutQueue = [];
    int currentIntervalIndex = 0;
    int remainingSeconds = 0;
    bool isPaused = false;
    bool soundEnabled = true;
    bool hapticEnabled = true;
    Map<String, dynamic> currentAudioHapticConfig = {};

    // --- Funzioni di Feedback ---
    void triggerHardwareFeedback(String phase) {
      final phaseConfig = currentAudioHapticConfig[phase] as Map<String, dynamic>?;
      if (phaseConfig == null) return;
      final String audioFile = phaseConfig['audio'] as String? ?? 'none';
      final String hapticType = phaseConfig['haptic'] as String? ?? 'none';

      if (soundEnabled && audioFile != 'none') {
        try { audioPlayer.play(AssetSource('audio/$audioFile.m4a')); } catch (e) { debugPrint('Audio error: $e'); }
      }
      if (hapticEnabled && hapticType != 'none') {
        Vibration.hasVibrator().then((hasV) { if (hasV) {
          switch (hapticType) {
            case 'single': Vibration.vibrate(duration: 150); break;
            case 'double': Vibration.vibrate(pattern: [0, 300, 150, 300]); break;
            case 'triple': Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 200]); break;
            case 'long': Vibration.vibrate(duration: 600); break;
          }
        }});
      }
    }

    // --- Motore Timer ---
    void runInterval() {
      if (currentIntervalIndex >= fullWorkoutQueue.length) {
        service.invoke('update', {'status': 'completed'});
        service.stopSelf();
        return;
      }

      final interval = fullWorkoutQueue[currentIntervalIndex] as Map<String, dynamic>;
      final int totalDuration = interval['duration'] as int;
      remainingSeconds = totalDuration;
      currentAudioHapticConfig = interval['audioHapticConfig'] as Map<String, dynamic>;

      final bool isLastInterval = (currentIntervalIndex == fullWorkoutQueue.length - 1);
      final String title = interval['title'] as String;
      final String? notes = interval['notes'] as String?;

      triggerHardwareFeedback('start');

      ticker?.cancel();
      ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (isPaused) return;

        remainingSeconds--;
        final double progress = (totalDuration > 0) ? (totalDuration - remainingSeconds) / totalDuration : 1.0;

        if (remainingSeconds <= 0) {
          timer.cancel();
          triggerHardwareFeedback('end');
          currentIntervalIndex++;
          runInterval();
          return;
        }

        service.invoke('update', {
          'remainingSeconds': remainingSeconds,
          'intervalProgress': progress,
          'isLastInterval': isLastInterval,
          'currentIntervalIndex': currentIntervalIndex,
          'title': title,
          'notes': notes,
          'status': 'running'
        });

        _updateNotification(localNotifications, title, _formatTime(remainingSeconds), notes);
      });
    }

    // --- Listeners Comandi ---
    service.on('startFullWorkout').listen((event) async {
      if (event == null) return;
      final prefs = await SharedPreferences.getInstance();
      soundEnabled = prefs.getBool('soundEnabled') ?? true;
      hapticEnabled = prefs.getBool('hapticFeedback') ?? true;
      fullWorkoutQueue = event['queue'] as List<dynamic>? ?? [];
      currentIntervalIndex = 0;
      isPaused = false;
      runInterval();
    });

    service.on('pause').listen((_) => isPaused = true);
    service.on('resume').listen((_) => isPaused = false);
    service.on('stop').listen((_) {
      ticker?.cancel();
      audioPlayer.dispose();
      service.stopSelf();
    });
  }

  // --- Funzioni Utility ---
  static void _updateNotification(FlutterLocalNotificationsPlugin notifications, String title, String content, String? notes) {
    notifications.show(
      id: notificationId,
      title: title.toUpperCase(),
      body: (notes != null && notes.isNotEmpty) ? '$content\n📌 $notes' : content,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
            channelId, 'ELAND Athletic Timer',
            channelDescription: 'Timer Notifications',
            ongoing: true, importance: Importance.max, priority: Priority.high,
            icon: '@mipmap/launcher_icon'
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: false),
      ),
    );
  }

  static String _formatTime(int totalSeconds) {
    final s = totalSeconds.abs();
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }
}