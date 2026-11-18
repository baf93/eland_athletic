import 'dart:async';
import 'dart:ui';

import 'package:eland_athletic/common/strings.dart';
import 'package:eland_athletic/common/theme.dart';
import 'package:eland_athletic/common/timer_core/models/interval_audio_haptic_config.dart';
import 'package:eland_athletic/common/timer_core/models/timercore_enums.dart';
import 'package:eland_live_update/eland_live_update.dart';
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

  /// Android 16+: the notification is posted as a Live Update (status bar
  /// chip, lock screen) instead of a media-style notification.
  static bool _liveUpdates = false;

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
    List<LiveUpdateSegment> segments = const [],
    int segmentProgress = 0,
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

    if (_liveUpdates) {
      final liveActions = showControls
          ? <LiveUpdateAction>[
              paused
                  ? LiveUpdateAction('resume', ElandStrings.of('notif_resume'),
                      'ic_notif_play')
                  : LiveUpdateAction('pause', ElandStrings.of('notif_pause'),
                      'ic_notif_pause'),
              if (canSkip)
                LiveUpdateAction(
                    'skipPhase', ElandStrings.of('notif_skip'), 'ic_notif_skip'),
              LiveUpdateAction(
                  'stop', ElandStrings.of('notif_stop'), 'ic_notif_stop'),
            ]
          : const <LiveUpdateAction>[];
      try {
        await ElandLiveUpdate.show(
          id: notificationId,
          channelId: channelId,
          title: title,
          body: body,
          smallIcon: 'ic_stat_eland',
          color: color.toARGB32(),
          payload: payload,
          chronometer: chronometer,
          countDown: countDown,
          whenMs: whenMs,
          // Shown in the status bar chip instead of the clock while paused.
          shortText: paused ? ElandStrings.of('notif_paused') : null,
          segments: segments,
          progress: segmentProgress,
          actions: liveActions,
        );
        return;
      } catch (e) {
        debugPrint('[ELAND] live update failed, falling back: $e');
        _liveUpdates = false;
      }
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
      title: title,
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

  /// "TABATA" -> "Tabata", "FOR TIME" -> "For Time"; acronyms stay.
  static String _niceCase(String text) {
    const acronyms = {'AMRAP', 'EMOM', 'HIIT', 'WOD'};
    if (text != text.toUpperCase()) return text;
    return text.split(' ').map((w) {
      if (w.isEmpty || acronyms.contains(w)) return w;
      return w[0] + w.substring(1).toLowerCase();
    }).join(' ');
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
    _liveUpdates = await ElandLiveUpdate.isSupported();
    Color accentColor() {
      final index = startupPrefs.getInt('primaryColor') ?? 0;
      final palette = ElandColors.customPalette;
      return palette[(index >= 0 && index < palette.length) ? index : 0];
    }

    // --- Variables for Internal status
    bool isPaused = true;
    DateTime? timerStartTime;
    Timer? ticker;
    int tickerGen = 0;
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

    /// Milliseconds elapsed in the current interval (pauses excluded).
    int elapsedMsNow() => timerStartTime == null
        ? accumulatedMsDuringStop
        : DateTime.now().difference(timerStartTime!).inMilliseconds +
            accumulatedMsDuringStop;

    /// Epoch ms at which the current interval clock read zero. The UI derives
    /// the displayed time from it with its own clock, so it does not depend
    /// on the timing of the messages coming from this isolate.
    int? clockAnchorMs() => (isPaused || timerStartTime == null)
        ? null
        : DateTime.now().millisecondsSinceEpoch - elapsedMsNow();

    void stopTicker() {
      tickerGen++;
      ticker?.cancel();
      ticker = null;
    }

    /// Calls [onTick] right after every whole second of the interval clock,
    /// so intervals end on time instead of drifting with a free-running
    /// periodic timer.
    void startAlignedTicker(void Function() onTick) {
      stopTicker();
      final gen = tickerGen;
      void schedule() {
        if (gen != tickerGen) return;
        final delay = (isPaused || timerStartTime == null)
            ? 250
            : 1000 - elapsedMsNow() % 1000 + 3;
        ticker = Timer(Duration(milliseconds: delay), () {
          if (gen != tickerGen) return;
          onTick();
          schedule();
        });
      }

      schedule();
    }

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

    /// What the athlete is doing now: "Work", "Rest", "Get ready", "AMRAP"...
    String intervalLabel(Map<String, dynamic> interval) {
      switch (interval['type']) {
        case 'preparation':
          return ElandStrings.of('get_ready');
        case 'rest':
          return ElandStrings.of('rest_time');
        case 'cooldown':
          return ElandStrings.of('cooldown_time');
      }
      if (interval['sourcePhase'] == 'tabata') {
        return ElandStrings.of('work_time');
      }
      return _niceCase(interval['title'] as String? ?? '');
    }

    /// "Work · Round 2/8"
    String intervalHeadline(Map<String, dynamic> interval) {
      final label = intervalLabel(interval);
      final totalRound = interval['totalRound'] as int? ?? 1;
      if (totalRound <= 1 || interval['type'] == 'preparation') return label;
      final round = ElandStrings.of('round');
      final roundLabel = round[0].toUpperCase() + round.substring(1);
      return '$label · $roundLabel ${interval['currentRound']}/$totalRound';
    }

    /// "Tabata · Set 1/3" or "Leg day · Phase 2/4" (preparation not counted).
    String intervalContext(Map<String, dynamic> interval) {
      final parts = <String>[];
      final workout = _niceCase(interval['workoutTitle'] as String? ?? '');
      if (workout.isNotEmpty &&
          workout.toLowerCase() != intervalLabel(interval).toLowerCase()) {
        parts.add(workout);
      }
      final totalSet = interval['totalSet'] as int? ?? 1;
      if (totalSet > 1) {
        parts.add('Set ${interval['currentSet']}/$totalSet');
      }
      final hasPrep = intervalQueue.isNotEmpty &&
          (intervalQueue.first as Map)['type'] == 'preparation';
      final offset = hasPrep ? 1 : 0;
      final totalPhases = (interval['totalPhases'] as int? ?? 1) - offset;
      final phase = (interval['currentPhase'] as int? ?? 1) - offset;
      if (totalPhases > 1 && phase >= 1) {
        parts.add('${ElandStrings.of('phase')} $phase/$totalPhases');
      }
      return parts.join(' · ');
    }

    /// Re-posts the live notification for the current interval.
    void refreshWorkoutNotification() {
      final interval = currentInterval();
      if (interval == null) return;

      final bool isForTime = interval['sourcePhase'] == 'fortime';
      final String headline = intervalHeadline(interval);
      final String context = intervalContext(interval);
      final now = DateTime.now().millisecondsSinceEpoch;
      // Derive the clock from the interval start, not from the ticker
      // fields: at interval start they are still 0 and the countdown would
      // anchor to "now" and run negative.
      final int durationMs = (interval['duration'] as int) * 1000;
      final int elapsedMs = timerStartTime == null
          ? accumulatedMsDuringStop
          : now - timerStartTime!.millisecondsSinceEpoch +
              accumulatedMsDuringStop;

      // Progress bar: one segment per interval, coloured by type.
      const restColor = Color(0xFF03DAC6);
      const idleColor = Color(0xFF757575);
      final segments = <LiveUpdateSegment>[];
      int doneSeconds = 0;
      for (var i = 0; i < intervalQueue.length; i++) {
        final item = intervalQueue[i] as Map<String, dynamic>;
        final int duration = (item['duration'] as int? ?? 0).clamp(1, 1 << 30);
        if (i < currentIntervalIndex) doneSeconds += duration;
        final Color c = switch (item['type']) {
          'work' => accentColor(),
          'rest' => restColor,
          _ => idleColor,
        };
        segments.add(LiveUpdateSegment(duration, c.toARGB32()));
      }
      final int currentDuration = (durationMs ~/ 1000).clamp(1, 1 << 30);
      final int segmentProgress =
          doneSeconds + (elapsedMs ~/ 1000).clamp(0, currentDuration);

      if (isPaused) {
        final shown = isForTime
            ? elapsedMs ~/ 1000
            : ((durationMs - elapsedMs) / 1000).ceil();
        _showLiveNotification(
          flutterLocalNotificationsPlugin,
          title: '${ElandStrings.of('notif_paused')} · $headline',
          body: [_formatDisplayTime(shown), if (context.isNotEmpty) context]
              .join(' · '),
          payload: 'open_workout_page',
          color: accentColor(),
          paused: true,
          progress: currentIntervalIndex,
          maxProgress: intervalQueue.length,
          segments: segments,
          segmentProgress: segmentProgress,
        );
        return;
      }

      _showLiveNotification(
        flutterLocalNotificationsPlugin,
        title: headline,
        body: context,
        payload: 'open_workout_page',
        color: accentColor(),
        chronometer: true,
        countDown: !isForTime,
        whenMs: isForTime ? now - elapsedMs : now + durationMs - elapsedMs,
        progress: currentIntervalIndex,
        maxProgress: intervalQueue.length,
        segments: segments,
        segmentProgress: segmentProgress,
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
        // The system clock already shows the time while running.
        body: running
            ? ''
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
        'anchorMs': clockAnchorMs(),
        'durationSeconds': interval['duration'] as int,
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
        'elapsedTotalMs': elapsed.inMilliseconds,
        'anchorMs': clockAnchorMs(),
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
      timerStartTime = DateTime.now();

      triggerAudioHapticFeedback(AudioHapticTrigger.start);

      // Update UI with new Interval details
      sendFullTimerStatus();
      sendRuntimeStatus();
      refreshWorkoutNotification();

      // Every Second update logic
      startAlignedTicker(() {
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

        // The chip/clock is rendered by the system; only the Live Update
        // progress bar needs a periodic nudge during long intervals.
        if (_liveUpdates && elapsedSeconds > 0 && elapsedSeconds % 10 == 0) {
          refreshWorkoutNotification();
        }

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
        stopTicker();
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
      timerStartTime = DateTime.now();

      triggerAudioHapticFeedback(AudioHapticTrigger.start);

      // Update UI with new Interval details
      sendFullTimerStatus();
      sendRuntimeStatus();
      refreshWorkoutNotification();

      // Every Second update logic
      startAlignedTicker(() {
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
          stopTicker();
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
      // No periodic messages: the stopwatch page renders its own clock from
      // the anchor sent here (it used to receive an update every 20 ms).
      stopTicker();
      sendFullStopWatchStatus();
    }

    void pause() {
      if (isPaused || timerStartTime == null) return;

      final Duration elapsed = DateTime.now().difference(timerStartTime!);
      accumulatedMsDuringStop += elapsed.inMilliseconds;
      timerStartTime = null;
      isPaused = true;

      if (stopWatchMode) {
        // In stopwatch mode, "pausing" just means to stop the ticker
        stopTicker();
        refreshStopwatchNotification();
      } else {
        pausedAt = workoutStartedAt != null ? DateTime.now() : null;
        countdownPlayer.pause();
        refreshWorkoutNotification();
      }
      if (stopWatchMode) {
        sendFullStopWatchStatus();
      } else {
        final duration = currentInterval()?['duration'] as int? ?? 0;
        final elapsed = elapsedMsNow() ~/ 1000;
        service.invoke('uiUpdate', {
          'status': 'paused',
          'anchorMs': null,
          'elapsedSeconds': elapsed,
          'remainingSeconds': duration - elapsed,
          'intervalProgress':
              duration > 0 ? (elapsed / duration).clamp(0.0, 1.0) : 1.0,
        });
      }
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
      if (!stopWatchMode) {
        service.invoke(
            'uiUpdate', {'status': 'running', 'anchorMs': clockAnchorMs()});
      }
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
      stopTicker();
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

      // Load every sound up front: phase changes then never wait for I/O.
      // A missing or slow sound must never block the start.
      try {
        await preloadAllNeededSounds(intervalQueue
                .expand(
                    (i) => (i['audioConfigs'] as List<dynamic>? ?? const []))
                .map((c) => const IntervalAudioConfig()
                    .fromJson(Map<String, dynamic>.from(c as Map)))
                .toList())
            .timeout(const Duration(seconds: 2));
      } catch (e) {
        debugPrint('[ELAND] sound preload failed: $e');
      }
      isPaused = false;
      sendFullTimerStatus();
      sendRuntimeStatus();
      runInterval();
    }));

    subscriptions.add(service.on('pause').listen((_) => pause()));
    subscriptions.add(service.on('resume').listen((_) => resume()));

    subscriptions.add(service.on('reset').listen((event) {
      if (stopWatchMode == false) return;

      stopTicker();
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

    void stopService() {
      debugPrint('[ELAND] timer service stopping');
      stopTicker();
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
    }

    subscriptions.add(service.on('stop').listen((_) => stopService()));

    subscriptions.add(service.on('requestStatus').listen((event) {
      if (stopWatchMode) {
        sendFullStopWatchStatus();
      } else {
        sendFullTimerStatus();
        sendRuntimeStatus();
      }
    }));

    subscriptions.add(service.on('startStopWatch').listen((event) {
      stopTicker();
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

      stopTicker();
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
        'elapsedTotalMs': 0,
        'anchorMs': null,
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

    void skipPhase() {
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

      stopTicker();
      isOvertime = false;
      accumulatedMsDuringStop = 0;
      timerStartTime = null;
      currentIntervalIndex++;
      runInterval();
    }

    subscriptions.add(service.on('skipPhase').listen((_) => skipPhase()));

    // Live Update buttons are delivered straight to this engine.
    if (_liveUpdates) {
      ElandLiveUpdate.setActionHandler((actionId) {
        switch (actionId) {
          case 'pause':
            pause();
          case 'resume':
            resume();
          case 'skipPhase':
            skipPhase();
          case 'stop':
            stopService();
        }
      });
    }

    service.invoke('serviceReady');
    debugPrint('[ELAND] timer service ready');
  }
}
