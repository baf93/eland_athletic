import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
class TimerBackgroundService {
  static const String channelId = 'eland_notification_channel';
  static const int notificationId = 102;

  /// Initialization of the notification channel and background service
  static Future<void> initialize() async {
    print("[BS] [+] Service initializing");
    final service = FlutterBackgroundService();
    const AndroidNotificationChannel notificationChannel = AndroidNotificationChannel(
      channelId,
      'ELAND notification channel',
      description: 'This channel is used for ELAND notifications',
      importance: Importance.low,
      playSound: false,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(notificationChannel);

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

  /// Utilities functions
  static void _updateNotification(FlutterLocalNotificationsPlugin notifications, String title, String content) async {
    await notifications.show(
      id: notificationId,
      title: title.toUpperCase(),
      body: content,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'ELAND notification channel',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          showWhen: false,
          onlyAlertOnce: true,
          icon: '@mipmap/launcher_icon'
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: false),
      ),
    );
  }

  static String _formatDisplayTime(int totalSeconds){
    final s = totalSeconds.abs();
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    print('[BS] [+] Service start');

    // --- Variables for Internal status
    bool isPaused = false;
    DateTime? timerStartTime;
    Timer? ticker;
    List<dynamic> intervalQueue = [];
    List<dynamic> uiPhaseList = [];
    bool soundEnabled = true;
    bool hapticEnabled = true;
    bool stopWatchMode = false;
    int remainingSeconds = 0;
    List<int> lapTimes = [];
    int currentIntervalIndex = 0;
    bool isLastPhase = false;
    double intervalProgress = 0.0;
    int accumulatedMsDuringStop = 0;


    // ---

    // Audio Setup
    final AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.setReleaseMode(ReleaseMode.stop);

    final AudioContext audioContext = AudioContext(
      android: AudioContextAndroid(isSpeakerphoneOn: true, stayAwake: true, contentType: AndroidContentType.sonification, usageType: AndroidUsageType.assistanceSonification, audioFocus: AndroidAudioFocus.gainTransientMayDuck),
      iOS: AudioContextIOS(category: AVAudioSessionCategory.playback, options: {AVAudioSessionOptions.duckOthers, AVAudioSessionOptions.mixWithOthers}),
    );
    await AudioPlayer.global.setAudioContext(audioContext);


    /// Utilities functions
    void triggerAudioHapticFeedback(String trigger){
      return; //TODO: Implementare gestione audio e feedback aptico
    }

    void sendFullTimerStatus(){
      if (intervalQueue.isEmpty) return;
      final interval = intervalQueue[currentIntervalIndex] as Map<String, dynamic>;

      service.invoke('uiUpdate', {
        'status': isPaused ? 'paused' : 'running',
        'remainingSeconds': remainingSeconds,
        'currentIntervalTitle': interval['title'],
        'currentIntervalNotes': interval['notes'],
        'intervalType': interval['type'],
        'currentPhaseIndex': interval['currentPhase'] as int,
        'totalPhases': interval['totalPhases'] as int,
        'isLastPhase': isLastPhase,
        'timerType': interval['sourcePhase'] as String,
        'intervalProgress': intervalProgress,
        'workoutTitle': interval['workoutTitle'] as String?,
        'workoutId': interval['workoutId'] as String?,
        'workoutPhaseSummary': uiPhaseList,
        'currentRound': interval['currentRound'] as int,
        'totalRound': interval['totalRound'] as int
      });
    }

    void sendFullStopWatchStatus(){

    }

    // --- Runners
    void runInterval(){
      // I'm at the end of the workout
      if(currentIntervalIndex >= intervalQueue.length){
        service.invoke('uiUpdate', {'status': 'completed', 'remainingSeconds': 0, 'intervalProgress': 1.0});
        ticker?.cancel();
        service.stopSelf();
        return;
      }

      timerStartTime = DateTime.now();

      final interval = intervalQueue[currentIntervalIndex] as Map<String, dynamic>;
      final int intervalDuration = interval['duration'] as int;
      remainingSeconds = intervalDuration;
      isLastPhase = interval['currentPhase'] as int == interval['totalPhases'] as int;

      // Update UI with new Interval details
      sendFullTimerStatus();

      // Every Second update logic
      ticker = Timer.periodic(const Duration(seconds: 1), (t){
        if (isPaused) return;

        final Duration elapsed = Duration(milliseconds: DateTime.now().difference(timerStartTime!).inMilliseconds + accumulatedMsDuringStop);
        remainingSeconds = Duration(seconds: intervalDuration - elapsed.inSeconds).inSeconds;
        intervalProgress = (intervalDuration > 0) ? (intervalDuration - remainingSeconds) / intervalDuration : 1.0;


        // End of interval. Next one
        if (remainingSeconds <= 0) {
          print("[++++] LAUNCHING NEW INTERVAL");
          ticker?.cancel();
          ticker = null;
          currentIntervalIndex++;
          runInterval();
          return;
        }

        print("[BS] UI Update from BS");
        /// Update UI with new values
        service.invoke('uiUpdate', {
          'status': 'running',
          'remainingSeconds': remainingSeconds,
          'intervalProgress': intervalProgress,
        });
      });
    }
    void runStopWatch(){
      timerStartTime = DateTime.now();

      ticker = Timer.periodic(const Duration(milliseconds: 50), (t) {

        final Duration elapsed = Duration(milliseconds: DateTime.now().difference(timerStartTime!).inMilliseconds + accumulatedMsDuringStop);


        service.invoke('uiUpdate', {
          'elapsedMilliseconds': elapsed.inMilliseconds % 1000,
          'elapsedSeconds': elapsed.inSeconds % 60,
          'elapsedMinutes': elapsed.inMinutes % 60,
          'elapsedHours': elapsed.inHours
        });
      });
    }

    // --- Listeners for actions
    service.on('startFullWorkout').listen((event) async {
      if (event == null) return;
      print('[BS] [+] Starting Full Workout');

      /// --- remove any previous timers
      ticker?.cancel();
      stopWatchMode = false;
      lapTimes = [];
      timerStartTime = null;
      currentIntervalIndex = 0;

      final prefs = await SharedPreferences.getInstance();
      soundEnabled = prefs.getBool('soundEnabled') ?? true;
      hapticEnabled = prefs.getBool('hapticFeedback') ?? true;

      intervalQueue = event['queue'] as List<dynamic>? ?? [];
      uiPhaseList = event['uiPhaseList'] as List<dynamic>? ?? [];
      isPaused = false;
      runInterval();
      print('[BS] [+] Full Workout Started');
    });

    service.on('pause').listen((event){
      if(stopWatchMode == true){
        // In stopwatch mode, "pausing" just means to stop the ticker and accumulate the elapsed time
        ticker?.cancel();
        if (timerStartTime != null) {
          final Duration elapsed = DateTime.now().difference(timerStartTime!);
          accumulatedMsDuringStop += elapsed.inMilliseconds;
          timerStartTime = null;
        }
      }else{
        final Duration elapsed = DateTime.now().difference(timerStartTime!);
        accumulatedMsDuringStop += elapsed.inMilliseconds;
        timerStartTime = null;
        isPaused = true;
      }
      service.invoke('uiUpdate', {'status': 'paused'});
    });

    service.on('resume').listen((event){
      if(stopWatchMode == true){
        // In stopwatch mode, "resuming" just means to start the ticker again and continue accumulating the elapsed time
        timerStartTime = DateTime.now();
        runStopWatch();
      }else {
        timerStartTime = DateTime.now();
        isPaused = false;
      }
      service.invoke('uiUpdate', {'status': 'running'});
    });

    service.on('reset').listen((event){
      if (stopWatchMode == false) return;

      ticker?.cancel();
      isPaused = true;
      timerStartTime = null;
      lapTimes = [];
      accumulatedMsDuringStop = 0;

      service.invoke('uiUpdate', {
        'status': 'paused',
        'elapsedMilliseconds': 0,
        'elapsedSeconds': 0,
        'elapsedMinutes': 0,
        'elapsedHours': 0
      });
    });

    service.on('stop').listen((event){
      ticker?.cancel();
      audioPlayer.dispose();
      service.stopSelf();
    });

    service.on('requestStatus').listen((event){
      if (stopWatchMode){
        sendFullStopWatchStatus();
      }else{
        sendFullTimerStatus();
      }
    });

    service.on('startStopWatch').listen((event){
      ticker?.cancel();
      stopWatchMode = true;
      lapTimes = [];
      intervalQueue = [];
      uiPhaseList = [];
      timerStartTime = null;
      accumulatedMsDuringStop = 0;

      isPaused = false;
      runStopWatch();
    });

    service.on('stopWatchLap').listen((event){
      if (timerStartTime != null) {
        final lap = DateTime.now().difference(timerStartTime!).inMilliseconds + accumulatedMsDuringStop;
        lapTimes.add(lap);
        
        service.invoke('uiUpdate', {'lapTimes': lapTimes});
      }
    });

    service.invoke('serviceReady');
  }
}