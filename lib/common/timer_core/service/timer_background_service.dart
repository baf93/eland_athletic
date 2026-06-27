import 'dart:async';
import 'package:eland_athletic/common/strings.dart';
import 'package:eland_athletic/common/timer_core/models/interval_audio_haptic_config.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
class TimerBackgroundService {
  static const String channelId = 'eland_notification_channel';
  static const int notificationId = 102;
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final Map<String, AudioPool> _audioPools = {};

  /// Initialization of the notification channel and background service
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();
    const AndroidNotificationChannel notificationChannel = AndroidNotificationChannel(
      channelId,
      'ELAND notification channel',
      description: 'This channel is used for ELAND notifications',
      importance: Importance.high,
      playSound: false,
      enableVibration: false,
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
          importance: Importance.defaultImportance,
          priority: Priority.high,
          ongoing: true,
          showWhen: false,
          onlyAlertOnce: true,
          icon: '@mipmap/launcher_icon'
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: false),
      ),
      payload: 'open_workout_page'
    );
  }

  static String _formatDisplayTime(int totalSeconds){
    final s = totalSeconds.abs();
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {

    _updateNotification(flutterLocalNotificationsPlugin, ElandStrings.of('notification_title'), ElandStrings.of('starting_workout'));
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
    int elapsedSeconds = 0;
    List<int> lapTimes = [];
    int currentIntervalIndex = 0;
    bool isLastPhase = false;
    double intervalProgress = 0.0;
    int accumulatedMsDuringStop = 0;
    List<IntervalAudioConfig> audioConfig = [];
    List<IntervalHapticConfig> hapticConfig = [];
    bool isOvertime = false;
    // ---

    // Audio Setup
    final AudioContext audioContext = AudioContext(
      android: AudioContextAndroid(stayAwake: true, contentType: AndroidContentType.music, usageType: AndroidUsageType.media, audioFocus: AndroidAudioFocus.gainTransientMayDuck),
      iOS: AudioContextIOS(category: AVAudioSessionCategory.playback, options: {AVAudioSessionOptions.duckOthers, AVAudioSessionOptions.mixWithOthers}),
    );
    await AudioPlayer.global.setAudioContext(audioContext);


    /// Utilities functions
    Future<void> preloadAllNeededSounds(List<IntervalAudioConfig> audioConfigs) async {
      final futures = audioConfigs
          .where((c) => c.fileName.isNotEmpty && !_audioPools.containsKey(c.fileName))
          .map((c) => AudioPool.create(source: AssetSource('audio/${c.fileName}'), maxPlayers: 2)
          .then((pool) => _audioPools[c.fileName] = pool));

      await Future.wait(futures);
    }

    void triggerAudioHapticFeedback(AudioHapticTrigger trigger){
      if (soundEnabled){
        final fileName = audioConfig.firstWhere(
                (c) => c.audioTrigger == trigger,
            orElse: () => IntervalAudioConfig(fileName: '')
        ).fileName;

        if (fileName.isNotEmpty && _audioPools.containsKey(fileName)) {
          _audioPools[fileName]!.start(volume: 1.0);
        }
      }

      if (hapticEnabled){
        final hapticPattern = hapticConfig.firstWhere((config) => config.trigger == trigger, orElse: () => IntervalHapticConfig(trigger: trigger, pattern: HapticPattern.none)).pattern;
        switch (hapticPattern){
          case HapticPattern.light:
            Vibration.vibrate(duration: 50);
            break;
          case HapticPattern.medium:
            Vibration.vibrate(duration: 100);
            break;
          case HapticPattern.heavy:
            Vibration.vibrate(duration: 200);
            break;
          case HapticPattern.doubleTap:
            Vibration.vibrate(pattern: [0, 50, 100, 50]);
            break;
          default:
            break;
        }
      }
    }

    void sendFullTimerStatus(){
      if (intervalQueue.isEmpty) return;
      final interval = intervalQueue[currentIntervalIndex] as Map<String, dynamic>;

      service.invoke('uiUpdate', {
        'status': isPaused ? 'paused' : 'running',
        'remainingSeconds': remainingSeconds,
        'elapsedSeconds': elapsedSeconds,
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
        'totalRound': interval['totalRound'] as int,
        'currentSet': interval['currentSet'] as int,
        'totalSet': interval['totalSet'] as int,
        'isOvertime': isOvertime,
      });
    }

    void sendFullStopWatchStatus(){

      final Duration elapsed = Duration(milliseconds: DateTime.now().difference(timerStartTime!).inMilliseconds + accumulatedMsDuringStop);


      service.invoke('uiUpdate', {
        'status': isPaused ? 'paused' : 'running',
        'elapsedMilliseconds': elapsed.inMilliseconds % 1000,
        'elapsedSeconds': elapsed.inSeconds % 60,
        'elapsedMinutes': elapsed.inMinutes % 60,
        'elapsedHours': elapsed.inHours,
        'lapTimes': lapTimes
      });
    }

    // --- Runners
    void runForTime() async {

      timerStartTime = DateTime.now();

      final interval = intervalQueue[currentIntervalIndex] as Map<String, dynamic>;
      final int intervalDuration = interval['duration'] as int;
      remainingSeconds = 0;
      elapsedSeconds = 0;
      intervalProgress = 0.0;
      isOvertime = false;
      isLastPhase = interval['currentPhase'] as int == interval['totalPhases'] as int;

      // Get Audio & Haptic config for current interval
      final List<dynamic> rawAudio = interval['audioConfigs'] as List<dynamic>;
      final List<dynamic> rawHaptic = interval['hapticConfigs'] as List<dynamic>;

      audioConfig = rawAudio.map((item) {
        return IntervalAudioConfig().fromJson(item as Map<String, dynamic>);
      }).toList();

      hapticConfig = rawHaptic.map((item) {
        return IntervalHapticConfig().fromJson(item as Map<String, dynamic>);
      }).toList();

      await preloadAllNeededSounds(audioConfig);

      triggerAudioHapticFeedback(AudioHapticTrigger.start);

      // Update UI with new Interval details
      sendFullTimerStatus();

      // Every Second update logic
      ticker = Timer.periodic(const Duration(seconds: 1), (t){
        if (isPaused) return;

        final Duration elapsed = Duration(milliseconds: DateTime.now().difference(timerStartTime!).inMilliseconds + accumulatedMsDuringStop);
        elapsedSeconds = elapsed.inSeconds;
        remainingSeconds = Duration(seconds: intervalDuration - elapsed.inSeconds).inSeconds;
        intervalProgress = (intervalDuration > 0) ? (intervalDuration - remainingSeconds) / intervalDuration : 1.0;

        _updateNotification(flutterLocalNotificationsPlugin, ElandStrings.of('notification_title'), '${_formatDisplayTime(elapsed.inSeconds)} | ${interval['title']} (${interval['currentPhase']}/${interval['totalPhases']})');

        if (intervalDuration ~/ 2 == remainingSeconds) {
          triggerAudioHapticFeedback(AudioHapticTrigger.half);
        }else if (remainingSeconds == 10) {
          triggerAudioHapticFeedback(AudioHapticTrigger.tenSeconds);
        }else if (remainingSeconds <= 3 && remainingSeconds > 0) {
          triggerAudioHapticFeedback(AudioHapticTrigger.lastThreeSeconds);
        }

        if (elapsedSeconds > intervalDuration) isOvertime = true;

        /// Update UI with new values
        service.invoke('uiUpdate', {
          'status': 'running',
          'elapsedSeconds': elapsedSeconds,
          'remainingSeconds': remainingSeconds,
          'intervalProgress': intervalProgress,
          'isOvertime': isOvertime
        });
      });
    }

    void runInterval() async {
      // I'm at the end of the workout
      if(currentIntervalIndex >= intervalQueue.length){
        service.invoke('uiUpdate', {'status': 'completed', 'remainingSeconds': 0, 'intervalProgress': 1.0});
        flutterLocalNotificationsPlugin.cancel(id: notificationId);
        ticker?.cancel();
        return;
      }

      if (intervalQueue[currentIntervalIndex]['sourcePhase'] == 'fortime') {
        runForTime();
        return;
      }

      timerStartTime = DateTime.now();

      final interval = intervalQueue[currentIntervalIndex] as Map<String, dynamic>;
      final int intervalDuration = interval['duration'] as int;
      remainingSeconds = intervalDuration;
      elapsedSeconds = 0;
      intervalProgress = 0.0;
      isLastPhase = interval['currentPhase'] as int == interval['totalPhases'] as int;

      // Get Audio & Haptic config for current interval
      final List<dynamic> rawAudio = interval['audioConfigs'] as List<dynamic>;
      final List<dynamic> rawHaptic = interval['hapticConfigs'] as List<dynamic>;

      audioConfig = rawAudio.map((item) {
        return IntervalAudioConfig().fromJson(item as Map<String, dynamic>);
      }).toList();

      hapticConfig = rawHaptic.map((item) {
        return IntervalHapticConfig().fromJson(item as Map<String, dynamic>);
      }).toList();

      await preloadAllNeededSounds(audioConfig);

      triggerAudioHapticFeedback(AudioHapticTrigger.start);

      // Update UI with new Interval details
      sendFullTimerStatus();

      // Every Second update logic
      ticker = Timer.periodic(const Duration(seconds: 1), (t){
        if (isPaused) return;

        final Duration elapsed = Duration(milliseconds: DateTime.now().difference(timerStartTime!).inMilliseconds + accumulatedMsDuringStop);
        elapsedSeconds = elapsed.inSeconds;
        remainingSeconds = Duration(seconds: intervalDuration - elapsed.inSeconds).inSeconds;
        intervalProgress = (intervalDuration > 0) ? (intervalDuration - remainingSeconds) / intervalDuration : 1.0;


        // End of interval. Next one
        if (remainingSeconds <= 0) {
          triggerAudioHapticFeedback(AudioHapticTrigger.end);
          ticker?.cancel();
          ticker = null;
          accumulatedMsDuringStop = 0;
          currentIntervalIndex++;
          runInterval();
          return;
        }

        _updateNotification(flutterLocalNotificationsPlugin, ElandStrings.of('notification_title'), '${_formatDisplayTime(remainingSeconds)} | ${interval['title']} (${interval['currentPhase']}/${interval['totalPhases']})');

        if (intervalDuration ~/ 2 == remainingSeconds) {
          triggerAudioHapticFeedback(AudioHapticTrigger.half);
        }else if (remainingSeconds == 10) {
          triggerAudioHapticFeedback(AudioHapticTrigger.tenSeconds);
        }else if (remainingSeconds <= 3 && remainingSeconds > 0) {
          triggerAudioHapticFeedback(AudioHapticTrigger.lastThreeSeconds);
        }

        /// Update UI with new values
        service.invoke('uiUpdate', {
          'status': 'running',
          'remainingSeconds': remainingSeconds,
          'elapsedSeconds': elapsedSeconds,
          'intervalProgress': intervalProgress,
        });
      });
    }

    void runStopWatch(){
      timerStartTime = DateTime.now();

      ticker = Timer.periodic(const Duration(milliseconds: 20), (t) {
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

      /// --- remove any previous timers
      ticker?.cancel();
      stopWatchMode = false;
      lapTimes = [];
      timerStartTime = null;
      currentIntervalIndex = 0;

      final prefs = await SharedPreferences.getInstance();
      soundEnabled = prefs.getBool('soundEnabled') ?? true;
      hapticEnabled = prefs.getBool('hapticFeedback') ?? true;
      final int prepTime = prefs.getInt('preparationTime') ?? 10;

      var queue = event['queue'] as List<dynamic>? ?? [];

      if (prepTime > 0) {
        intervalQueue = [
          {
            'id': 'prep_phase',
            'title': ElandStrings.of('timer_preparation'),
            'duration': prepTime,
            'type': 'preparation',
            'sourcePhase': 'preparation',
            'currentPhase': 1,
            'totalPhases': queue[0]['totalPhases']+1 ?? 0,
            'currentRound': 1,
            'totalRound': 1,
            'workoutTitle': queue[0]['workoutTitle'] ?? '',
            'workoutId': queue[0]['workoutId'] ?? '',
            'currentSet': 1,
            'totalSet': 1,
            'audioConfigs': [
              {'audioTrigger': 'start', 'fileName': 'getready.m4a'},
              {'audioTrigger': 'lastThreeSeconds', 'fileName': 'beep.m4a'},
            ],
            'hapticConfigs': [
              {'trigger': 'start', 'pattern': 'heavy'},
              {'trigger': 'lastThreeSeconds', 'pattern': 'light'},
            ],

          }
        ];

        uiPhaseList = [
          {
           'title': ElandStrings.of('timer_preparation'),
           'details': '$prepTime s',
          }
        ];


        queue.asMap().forEach((index, item) {
          item['currentPhase'] = (item['currentPhase'] ?? 0) + 1;
          item['totalPhases'] = (item['totalPhases'] ?? 0) + 1;
        });
      }


      intervalQueue.addAll(event['queue'] as List<dynamic>? ?? []);
      uiPhaseList.addAll(event['uiPhaseList'] as List<dynamic>? ?? []);
      isPaused = false;
      runInterval();
    });

    service.on('pause').listen((event){

      if (timerStartTime == null) return;

      if(stopWatchMode == true){
        // In stopwatch mode, "pausing" just means to stop the ticker and accumulate the elapsed time
        ticker?.cancel();
        if (timerStartTime != null) {
          final Duration elapsed = DateTime.now().difference(timerStartTime!);
          accumulatedMsDuringStop += elapsed.inMilliseconds;
          timerStartTime = null;
        }
        isPaused = true;
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
        isPaused = false;
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
      flutterLocalNotificationsPlugin.cancel(id: notificationId);
      _audioPools.forEach((key, pool) => pool.dispose());
      _audioPools.clear();
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
      _updateNotification(flutterLocalNotificationsPlugin, ElandStrings.of('notification_title'), ElandStrings.of('stopwatch_running'));

      isPaused = true;
    });

    service.on('recordLap').listen((event){
      if (timerStartTime != null) {
        final lap = DateTime.now().difference(timerStartTime!).inMilliseconds + accumulatedMsDuringStop;
        lapTimes.add(lap);
        
        service.invoke('uiUpdate', {'lapTimes': lapTimes});
      }
    });

    service.on('skipPhase').listen((event){
      if (stopWatchMode == true) return;

      ticker?.cancel();
      isOvertime = false;
      accumulatedMsDuringStop = 0;
      timerStartTime = null;
      currentIntervalIndex++;
      runInterval();
    });

    service.invoke('serviceReady');
  }
}