import 'dart:async';
import 'dart:ui';

import 'package:eland_athletic/common/strings.dart';
import 'package:eland_athletic/common/theme.dart';
import 'package:eland_athletic/common/timer_core/models/interval_audio_haptic_config.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Commands that can be sent to the background service from notification
/// action buttons. The action id is forwarded verbatim to the service.
const Set<String> kTimerNotificationActions = {
  'pause',
  'resume',
  'skipPhase',
  'stop',
};

/// Handles taps on the live-notification buttons when they are dispatched to
/// a background isolate (Android delivers actions that do not open the UI
/// there). It just relays the command to the timer service.
@pragma('vm:entry-point')
void timerNotificationActionHandler(NotificationResponse response) {
  DartPluginRegistrant.ensureInitialized();
  final actionId = response.actionId;
  if (actionId != null && kTimerNotificationActions.contains(actionId)) {
    FlutterBackgroundService().invoke(actionId);
  }
}

@pragma('vm:entry-point')
class TimerBackgroundService {
  static const String channelId = 'eland_notification_channel';
  static const int notificationId = 102;
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final Map<String, AudioPool> _audioPools = {};

  /// Initialization of the notification channel and background service
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();
    const AndroidNotificationChannel notificationChannel =
        AndroidNotificationChannel(
      channelId,
      'ELAND notification channel',
      description: 'This channel is used for ELAND notifications',
      importance: Importance.defaultImportance,
      playSound: false,
      enableVibration: false,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(notificationChannel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: TimerBackgroundService.onStart,
        autoStart: false,
        // The service must only run while a workout/stopwatch is active.
        // The plugin default (true) restarts it at every boot and app update,
        // leaving a stray "ELAND" notification in the status bar.
        autoStartOnBoot: false,
        isForegroundMode: true,
        notificationChannelId: channelId,
        initialNotificationTitle: ElandStrings.of('notification_title'),
        initialNotificationContent: ElandStrings.of('starting_workout'),
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: (service) => Future.value(true),
      ),
    );
  }

  /// Live notification: the system renders the clock itself (chronometer), so
  /// it is only re-posted when something changes (new interval, pause...).
  static Future<void> _showLiveNotification(
    FlutterLocalNotificationsPlugin notifications, {
    required String title,
    required String body,
    required String payload,
    required Color color,
    bool paused = false,
    bool chronometer = false,
    bool countDown = false,
    int? whenMs,
    int progress = 0,
    int maxProgress = 0,
    bool showControls = true,
    bool canSkip = true,
  }) async {
    AndroidNotificationAction action(String id, String labelKey, String icon) {
      return AndroidNotificationAction(
        id,
        ElandStrings.of(labelKey),
        icon: DrawableResourceAndroidBitmap(icon),
        showsUserInterface: false,
        cancelNotification: false,
      );
    }

    final actions = showControls
        ? <AndroidNotificationAction>[
            paused
                ? action('resume', 'notif_resume', 'ic_notif_play')
                : action('pause', 'notif_pause', 'ic_notif_pause'),
            if (canSkip) action('skipPhase', 'notif_skip', 'ic_notif_skip'),
            action('stop', 'notif_stop', 'ic_notif_stop'),
          ]
        : null;

    await notifications.show(
      id: notificationId,
      title: title.toUpperCase(),
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'ELAND notification channel',
          importance: Importance.defaultImportance,
          priority: Priority.high,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          showWhen: chronometer,
          when: chronometer ? whenMs : null,
          usesChronometer: chronometer,
          chronometerCountDown: countDown,
          showProgress: maxProgress > 0,
          maxProgress: maxProgress,
          progress: progress,
          icon: 'ic_stat_eland',
          color: color,
          category: AndroidNotificationCategory.workout,
          visibility: NotificationVisibility.public,
          styleInformation: const MediaStyleInformation(),
          actions: actions,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: false,
        ),
      ),
      payload: payload,
    );
  }

  static String _formatDisplayTime(int totalSeconds) {
    final s = totalSeconds.abs();
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    debugPrint('[ELAND] timer service starting');

    final startupPrefs = await SharedPreferences.getInstance();
    ElandStrings.initLocale(startupPrefs.getString('language') ??
        PlatformDispatcher.instance.locale.languageCode);
    Color accentColor() {
      final index = startupPrefs.getInt('primaryColor') ?? 0;
      final palette = ElandColors.customPalette;
      return palette[(index >= 0 && index < palette.length) ? index : 0];
    }

    // --- Variables for Internal status
    bool isPaused = true;
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
    List<StreamSubscription> subscriptions = [];
    final AudioPlayer countdownPlayer = AudioPlayer();

    // Workout-level bookkeeping used for the history log.
    DateTime? workoutStartedAt; // first non-preparation interval
    DateTime? pausedAt;
    int workoutPausedMs = 0;
    List<Map<String, dynamic>> phaseResults = [];
    // ---

    // Audio Setup
    _audioPools.clear();

    final AudioContext audioContext = AudioContext(
      android: AudioContextAndroid(
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {
          AVAudioSessionOptions.duckOthers,
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    );

    await AudioPlayer.global.setAudioContext(audioContext);

    /// Utilities functions
    Future<void> preloadAllNeededSounds(
        List<IntervalAudioConfig> audioConfigs) async {
      final futures = audioConfigs
          .where((c) =>
              c.fileName.isNotEmpty && !_audioPools.containsKey(c.fileName))
          .map((c) => AudioPool.create(
                source: AssetSource('audio/${c.fileName}'),
                maxPlayers: 2,
              ).then((pool) => _audioPools[c.fileName] = pool));

      await Future.wait(futures);
    }

    void triggerAudioHapticFeedback(AudioHapticTrigger trigger,
        {bool audioActive = true}) {
      if (soundEnabled && audioActive) {
        final fileName = audioConfig
            .firstWhere(
              (c) => c.audioTrigger == trigger,
              orElse: () => IntervalAudioConfig(fileName: ''),
            )
            .fileName;

        if (trigger == AudioHapticTrigger.lastThreeSeconds) {
          if (fileName.isNotEmpty) {
            countdownPlayer.play(AssetSource('audio/$fileName'), volume: 1.0);
          }
        } else {
          if (fileName.isNotEmpty && _audioPools.containsKey(fileName)) {
            _audioPools[fileName]!.start(volume: 1.0);
          }
        }
      }

      if (hapticEnabled) {
        final hapticPattern = hapticConfig
            .firstWhere(
              (config) => config.trigger == trigger,
              orElse: () => IntervalHapticConfig(
                trigger: trigger,
                pattern: HapticPattern.none,
              ),
            )
            .pattern;
        switch (hapticPattern) {
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

    Map<String, dynamic>? currentInterval() {
      if (intervalQueue.isEmpty || currentIntervalIndex >= intervalQueue.length) {
        return null;
      }
      return intervalQueue[currentIntervalIndex] as Map<String, dynamic>;
    }

    int activeWorkoutSeconds() {
      if (workoutStartedAt == null) return 0;
      var pausedMs = workoutPausedMs;
      if (pausedAt != null) {
        pausedMs += DateTime.now().difference(pausedAt!).inMilliseconds;
      }
      final ms =
          DateTime.now().difference(workoutStartedAt!).inMilliseconds - pausedMs;
      return ms < 0 ? 0 : ms ~/ 1000;
    }

    String intervalSubtitle(Map<String, dynamic> interval) {
      final parts = <String>[interval['title'] as String? ?? ''];
      final totalRound = interval['totalRound'] as int? ?? 1;
      final totalSet = interval['totalSet'] as int? ?? 1;
      if (totalRound > 1) {
        parts.add(
            '${ElandStrings.of('round').toUpperCase()} ${interval['currentRound']}/$totalRound');
      }
      if (totalSet > 1) {
        parts.add('SET ${interval['currentSet']}/$totalSet');
      }
      parts.add(
          '${ElandStrings.of('phase').toUpperCase()} ${interval['currentPhase']}/${interval['totalPhases']}');
      return parts.where((p) => p.isNotEmpty).join(' · ');
    }

    /// Re-posts the live notification for the current interval.
    void refreshWorkoutNotification() {
      final interval = currentInterval();
      if (interval == null) return;

      final bool isForTime = interval['sourcePhase'] == 'fortime';
      final String title = (interval['workoutTitle'] as String?)?.isNotEmpty ==
              true
          ? interval['workoutTitle'] as String
          : ElandStrings.of('notification_title');
      final subtitle = intervalSubtitle(interval);
      final now = DateTime.now().millisecondsSinceEpoch;
      // Derive the clock from the interval start, not from the ticker
      // fields: at interval start they are still 0 and the countdown would
      // anchor to "now" and run negative.
      final int durationMs = (interval['duration'] as int) * 1000;
      final int elapsedMs = timerStartTime == null
          ? accumulatedMsDuringStop
          : now - timerStartTime!.millisecondsSinceEpoch +
              accumulatedMsDuringStop;

      if (isPaused) {
        final shown = isForTime
            ? elapsedMs ~/ 1000
            : ((durationMs - elapsedMs) / 1000).ceil();
        _showLiveNotification(
          flutterLocalNotificationsPlugin,
          title: title,
          body:
              '${ElandStrings.of('notif_paused')} · ${_formatDisplayTime(shown)} · $subtitle',
          payload: 'open_workout_page',
          color: accentColor(),
          paused: true,
          progress: currentIntervalIndex,
          maxProgress: intervalQueue.length,
        );
        return;
      }

      _showLiveNotification(
        flutterLocalNotificationsPlugin,
        title: title,
        body: subtitle,
        payload: 'open_workout_page',
        color: accentColor(),
        chronometer: true,
        countDown: !isForTime,
        whenMs: isForTime ? now - elapsedMs : now + durationMs - elapsedMs,
        progress: currentIntervalIndex,
        maxProgress: intervalQueue.length,
      );
    }

    void refreshStopwatchNotification() {
      int elapsedMs = accumulatedMsDuringStop;
      if (timerStartTime != null) {
        elapsedMs += DateTime.now().difference(timerStartTime!).inMilliseconds;
      }
      final running = !isPaused && timerStartTime != null;
      _showLiveNotification(
        flutterLocalNotificationsPlugin,
        title: ElandStrings.of('timer_stopwatch'),
        body: running
            ? ElandStrings.of('stopwatch_running')
            : '${ElandStrings.of('notif_paused')} · ${_formatDisplayTime(elapsedMs ~/ 1000)}',
        payload: 'open_stopwatch_page',
        color: accentColor(),
        paused: !running,
        chronometer: running,
        whenMs: DateTime.now().millisecondsSinceEpoch - elapsedMs,
        canSkip: false,
      );
    }

    void sendFullTimerStatus() {
      final interval = currentInterval();
      if (interval == null) return;

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

    void sendFullStopWatchStatus() {
      Duration elapsed = Duration(milliseconds: accumulatedMsDuringStop);

      if (timerStartTime != null) {
        elapsed = Duration(
            milliseconds:
                DateTime.now().difference(timerStartTime!).inMilliseconds +
                    accumulatedMsDuringStop);
      }

      service.invoke('uiUpdate', {
        'status': isPaused ? 'paused' : 'running',
        'elapsedMilliseconds': elapsed.inMilliseconds % 1000,
        'elapsedSeconds': elapsed.inSeconds % 60,
        'elapsedMinutes': elapsed.inMinutes % 60,
        'elapsedHours': elapsed.inHours,
        'lapTimes': lapTimes,
      });
    }

    void sendRuntimeStatus() {
      final interval = currentInterval();
      if (interval == null) return;

      service.invoke('runtimeUpdate', {
        'status': isPaused ? 'paused' : 'running',
        'workoutId': interval['workoutId'] as String?,
        'workoutTitle': interval['workoutTitle'] as String?,
        'remainingSeconds': remainingSeconds,
        'elapsedSeconds': elapsedSeconds,
        'phaseTitle': interval['title'],
        'currentRound': interval['currentRound'] as int,
        'totalRound': interval['totalRound'] as int,
        'currentSet': interval['currentSet'] as int,
        'totalSet': interval['totalSet'] as int,
        'intervalProgress': intervalProgress,
        'isOvertime': isOvertime,
      });
    }

    Future<void> loadIntervalFeedback(Map<String, dynamic> interval) async {
      final List<dynamic> rawAudio =
          interval['audioConfigs'] as List<dynamic>? ?? [];
      final List<dynamic> rawHaptic =
          interval['hapticConfigs'] as List<dynamic>? ?? [];

      audioConfig = rawAudio
          .map((item) => const IntervalAudioConfig()
              .fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      hapticConfig = rawHaptic
          .map((item) => const IntervalHapticConfig()
              .fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      await preloadAllNeededSounds(audioConfig);
    }

    void markWorkoutStartedIfNeeded(Map<String, dynamic> interval) {
      if (workoutStartedAt == null && interval['sourcePhase'] != 'preparation') {
        workoutStartedAt = DateTime.now();
        workoutPausedMs = 0;
        pausedAt = isPaused ? DateTime.now() : null;
      }
    }

    // --- Runners
    void runForTime() async {
      timerStartTime = DateTime.now();

      final interval = currentInterval()!;
      final int intervalDuration = interval['duration'] as int;
      remainingSeconds = 0;
      elapsedSeconds = 0;
      intervalProgress = 0.0;
      isOvertime = false;
      isLastPhase =
          interval['currentPhase'] as int == interval['totalPhases'] as int;
      markWorkoutStartedIfNeeded(interval);

      await loadIntervalFeedback(interval);

      triggerAudioHapticFeedback(AudioHapticTrigger.start);

      // Update UI with new Interval details
      sendFullTimerStatus();
      sendRuntimeStatus();
      refreshWorkoutNotification();

      // Every Second update logic
      ticker?.cancel();
      ticker = Timer.periodic(const Duration(seconds: 1), (t) {
        if (isPaused || timerStartTime == null) return;

        final Duration elapsed = Duration(
            milliseconds:
                DateTime.now().difference(timerStartTime!).inMilliseconds +
                    accumulatedMsDuringStop);
        elapsedSeconds = elapsed.inSeconds;
        remainingSeconds = intervalDuration - elapsed.inSeconds;
        intervalProgress = (intervalDuration > 0)
            ? (intervalDuration - remainingSeconds) / intervalDuration
            : 1.0;

        if (intervalDuration ~/ 2 == remainingSeconds) {
          triggerAudioHapticFeedback(AudioHapticTrigger.half);
        } else if (remainingSeconds == 10) {
          triggerAudioHapticFeedback(AudioHapticTrigger.tenSeconds);
        } else if (remainingSeconds == 3) {
          triggerAudioHapticFeedback(AudioHapticTrigger.lastThreeSeconds);
        } else if (remainingSeconds < 3 && remainingSeconds > 0) {
          triggerAudioHapticFeedback(AudioHapticTrigger.lastThreeSeconds,
              audioActive: false);
        }

        if (elapsedSeconds > intervalDuration) isOvertime = true;

        if (elapsedSeconds == intervalDuration + 1) {
          triggerAudioHapticFeedback(AudioHapticTrigger.overtime);
        }

        /// Update UI with new values
        service.invoke('uiUpdate', {
          'status': 'running',
          'elapsedSeconds': elapsedSeconds,
          'remainingSeconds': remainingSeconds,
          'intervalProgress': intervalProgress,
          'isOvertime': isOvertime,
        });
        sendRuntimeStatus();
      });
    }

    void runInterval() async {
      // I'm at the end of the workout
      if (currentIntervalIndex >= intervalQueue.length) {
        triggerAudioHapticFeedback(AudioHapticTrigger.end);
        ticker?.cancel();
        service.invoke('uiUpdate', {
          'status': 'completed',
          'remainingSeconds': 0,
          'intervalProgress': 1.0,
          'activeSeconds': activeWorkoutSeconds(),
          'phaseResults': phaseResults,
        });
        flutterLocalNotificationsPlugin.cancel(id: notificationId);
        return;
      }

      if (currentInterval()!['sourcePhase'] == 'fortime') {
        runForTime();
        return;
      }

      timerStartTime = DateTime.now();

      final interval = currentInterval()!;
      final int intervalDuration = interval['duration'] as int;
      remainingSeconds = intervalDuration;
      elapsedSeconds = 0;
      intervalProgress = 0.0;
      isOvertime = false;
      isLastPhase =
          interval['currentPhase'] as int == interval['totalPhases'] as int;
      markWorkoutStartedIfNeeded(interval);

      await loadIntervalFeedback(interval);

      triggerAudioHapticFeedback(AudioHapticTrigger.start);

      // Update UI with new Interval details
      sendFullTimerStatus();
      sendRuntimeStatus();
      refreshWorkoutNotification();

      // Every Second update logic
      ticker?.cancel();
      ticker = Timer.periodic(const Duration(seconds: 1), (t) {
        if (isPaused || timerStartTime == null) return;

        final Duration elapsed = Duration(
            milliseconds:
                DateTime.now().difference(timerStartTime!).inMilliseconds +
                    accumulatedMsDuringStop);
        elapsedSeconds = elapsed.inSeconds;
        remainingSeconds = intervalDuration - elapsed.inSeconds;
        intervalProgress = (intervalDuration > 0)
            ? (intervalDuration - remainingSeconds) / intervalDuration
            : 1.0;

        // End of interval. Next one
        if (remainingSeconds <= 0) {
          ticker?.cancel();
          ticker = null;
          accumulatedMsDuringStop = 0;
          currentIntervalIndex++;
          runInterval();
          return;
        }

        if (intervalDuration ~/ 2 == remainingSeconds) {
          triggerAudioHapticFeedback(AudioHapticTrigger.half);
        } else if (remainingSeconds == 10) {
          triggerAudioHapticFeedback(AudioHapticTrigger.tenSeconds);
        } else if (remainingSeconds == 3) {
          triggerAudioHapticFeedback(AudioHapticTrigger.lastThreeSeconds);
        } else if (remainingSeconds < 3 && remainingSeconds > 0) {
          triggerAudioHapticFeedback(AudioHapticTrigger.lastThreeSeconds,
              audioActive: false);
        }

        /// Update UI with new values
        service.invoke('uiUpdate', {
          'status': 'running',
          'remainingSeconds': remainingSeconds,
          'elapsedSeconds': elapsedSeconds,
          'intervalProgress': intervalProgress,
        });
        sendRuntimeStatus();
      });
    }

    void runStopWatch() {
      timerStartTime = DateTime.now();

      ticker?.cancel();
      ticker = Timer.periodic(const Duration(milliseconds: 20), (t) {
        final Duration elapsed = Duration(
            milliseconds:
                DateTime.now().difference(timerStartTime!).inMilliseconds +
                    accumulatedMsDuringStop);

        service.invoke('uiUpdate', {
          'elapsedMilliseconds': elapsed.inMilliseconds % 1000,
          'elapsedSeconds': elapsed.inSeconds % 60,
          'elapsedMinutes': elapsed.inMinutes % 60,
          'elapsedHours': elapsed.inHours,
        });
      });
    }

    void pause() {
      if (isPaused || timerStartTime == null) return;

      final Duration elapsed = DateTime.now().difference(timerStartTime!);
      accumulatedMsDuringStop += elapsed.inMilliseconds;
      timerStartTime = null;
      isPaused = true;

      if (stopWatchMode) {
        // In stopwatch mode, "pausing" just means to stop the ticker
        ticker?.cancel();
        refreshStopwatchNotification();
      } else {
        pausedAt = workoutStartedAt != null ? DateTime.now() : null;
        countdownPlayer.pause();
        refreshWorkoutNotification();
      }
      service.invoke('uiUpdate', {'status': 'paused'});
      sendRuntimeStatus();
    }

    void resume() {
      if (!isPaused) return;
      timerStartTime = DateTime.now();
      isPaused = false;

      if (stopWatchMode) {
        runStopWatch();
        refreshStopwatchNotification();
      } else {
        if (pausedAt != null) {
          workoutPausedMs +=
              DateTime.now().difference(pausedAt!).inMilliseconds;
          pausedAt = null;
        }
        countdownPlayer.resume();
        refreshWorkoutNotification();
      }
      service.invoke('uiUpdate', {'status': 'running'});
      sendRuntimeStatus();
    }

    // --- Listeners for actions
    subscriptions.add(service.on('startFullWorkout').listen((event) async {
      if (event == null) return;

      final queue = (event['queue'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      if (queue.isEmpty) return;

      /// --- reset every piece of state left by a previous run
      ticker?.cancel();
      stopWatchMode = false;
      lapTimes = [];
      timerStartTime = null;
      currentIntervalIndex = 0;
      accumulatedMsDuringStop = 0;
      isOvertime = false;
      intervalQueue = [];
      uiPhaseList = [];
      workoutStartedAt = null;
      pausedAt = null;
      workoutPausedMs = 0;
      phaseResults = [];

      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      soundEnabled = prefs.getBool('soundEnabled') ?? true;
      hapticEnabled = prefs.getBool('hapticFeedback') ?? true;
      final int prepTime = prefs.getInt('preparationTime') ?? 10;
      ElandStrings.initLocale(prefs.getString('language') ??
          PlatformDispatcher.instance.locale.languageCode);

      if (prepTime > 0) {
        final first = queue.first;
        intervalQueue = [
          {
            'id': 'prep_phase',
            'title': ElandStrings.of('timer_preparation'),
            'duration': prepTime,
            'type': 'preparation',
            'sourcePhase': 'preparation',
            'currentPhase': 1,
            'totalPhases': (first['totalPhases'] as int? ?? 0) + 1,
            'currentRound': 1,
            'totalRound': 1,
            'workoutTitle': first['workoutTitle'] ?? '',
            'workoutId': first['workoutId'] ?? '',
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

        for (final item in queue) {
          item['currentPhase'] = (item['currentPhase'] as int? ?? 0) + 1;
          item['totalPhases'] = (item['totalPhases'] as int? ?? 0) + 1;
        }
      }

      intervalQueue.addAll(queue);
      uiPhaseList.addAll(event['uiPhaseList'] as List<dynamic>? ?? []);
      isPaused = false;
      sendFullTimerStatus();
      sendRuntimeStatus();
      runInterval();
    }));

    subscriptions.add(service.on('pause').listen((_) => pause()));
    subscriptions.add(service.on('resume').listen((_) => resume()));

    subscriptions.add(service.on('reset').listen((event) {
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
        'elapsedHours': 0,
      });
      refreshStopwatchNotification();
    }));

    subscriptions.add(service.on('stop').listen((event) {
      debugPrint('[ELAND] timer service stopping');
      ticker?.cancel();
      // Lets an open workout/stopwatch page close itself when the stop comes
      // from the notification.
      service.invoke('serviceStopped');
      flutterLocalNotificationsPlugin.cancel(id: notificationId);

      countdownPlayer.dispose();

      _audioPools.forEach((key, pool) => pool.dispose());
      _audioPools.clear();
      for (var sub in subscriptions) {
        sub.cancel();
      }
      subscriptions.clear();
      service.stopSelf();
    }));

    subscriptions.add(service.on('requestStatus').listen((event) {
      if (stopWatchMode) {
        sendFullStopWatchStatus();
      } else {
        sendFullTimerStatus();
        sendRuntimeStatus();
      }
    }));

    subscriptions.add(service.on('startStopWatch').listen((event) {
      ticker?.cancel();
      stopWatchMode = true;
      lapTimes = [];
      intervalQueue = [];
      uiPhaseList = [];
      timerStartTime = null;
      accumulatedMsDuringStop = 0;
      isPaused = true;
      sendFullStopWatchStatus();
      refreshStopwatchNotification();
    }));

    subscriptions.add(service.on('resetStopWatch').listen((event) {
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
        'elapsedHours': 0,
        'lapTimes': null,
      });
      refreshStopwatchNotification();
    }));

    subscriptions.add(service.on('recordLap').listen((event) {
      if (timerStartTime != null) {
        final lap = DateTime.now().difference(timerStartTime!).inMilliseconds +
            accumulatedMsDuringStop;
        lapTimes.add(lap);

        service.invoke('uiUpdate', {'lapTimes': lapTimes});
      }
    }));

    subscriptions.add(service.on('skipPhase').listen((event) {
      if (stopWatchMode == true) return;
      final interval = currentInterval();
      if (interval == null) return;

      // "Done" on a For Time phase: the elapsed time is the athlete's result.
      if (interval['sourcePhase'] == 'fortime') {
        int ms = accumulatedMsDuringStop;
        if (timerStartTime != null) {
          ms += DateTime.now().difference(timerStartTime!).inMilliseconds;
        }
        phaseResults.add({
          'phase': interval['currentPhase'],
          'type': 'fortime',
          'title': interval['title'],
          'seconds': ms ~/ 1000,
          'capSeconds': interval['duration'],
        });
      }

      ticker?.cancel();
      isOvertime = false;
      accumulatedMsDuringStop = 0;
      timerStartTime = null;
      currentIntervalIndex++;
      runInterval();
    }));

    service.invoke('serviceReady');
    debugPrint('[ELAND] timer service ready');
  }
}
