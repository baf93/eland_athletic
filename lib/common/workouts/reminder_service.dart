import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../strings.dart';
import '../timer_core/models/timer_block.dart';
import 'models.dart';

/// Schedules the weekly "time to train" notifications of custom workouts.
abstract class ReminderScheduler {
  Future<void> schedule(CustomWorkout workout);
  Future<void> cancel(String workoutId);
  Future<void> rescheduleAll(List<CustomWorkout> workouts);
}

class ReminderService implements ReminderScheduler {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  static const String channelId = 'eland_reminders';
  static const String payloadPrefix = 'workout:';

  /// Ids below this value belong to other notifications (e.g. the timer).
  static const int _firstReminderId = 1000;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> initialize() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('[ELAND] timezone lookup failed, reminders use UTC: $e');
    }

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(AndroidNotificationChannel(
          channelId,
          ElandStrings.of('reminder_channel_name'),
          description: ElandStrings.of('reminder_channel_desc'),
          importance: Importance.high,
        ));
    _ready = true;
  }

  /// Stable across app runs (String.hashCode is not guaranteed to be).
  static int notificationIdFor(String workoutId, int weekday) {
    var hash = 0x811c9dc5;
    for (final unit in workoutId.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return _firstReminderId + (hash % 200000) * 8 + weekday;
  }

  /// Next occurrence of [weekday] (1 = Monday) at [hour]:[minute].
  static tz.TZDateTime nextInstance(
    int weekday,
    int hour,
    int minute, {
    tz.TZDateTime? from,
  }) {
    final now = from ?? tz.TZDateTime.now(tz.local);
    var date =
        tz.TZDateTime(now.location, now.year, now.month, now.day, hour, minute);
    while (date.weekday != weekday || !date.isAfter(now)) {
      date = tz.TZDateTime(
          now.location, date.year, date.month, date.day + 1, hour, minute);
    }
    return date;
  }

  @override
  Future<void> schedule(CustomWorkout workout) async {
    await initialize();
    await cancel(workout.id);
    final reminder = workout.reminder;
    if (reminder == null || !reminder.isActive) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        ElandStrings.of('reminder_channel_name'),
        channelDescription: ElandStrings.of('reminder_channel_desc'),
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_notif_alarm',
        category: AndroidNotificationCategory.reminder,
      ),
    );

    for (final day in reminder.weekdays) {
      try {
        await _plugin.zonedSchedule(
          id: notificationIdFor(workout.id, day),
          title: workout.name.toUpperCase(),
          body:
              '${ElandStrings.of('reminder_body')} · ${TimerBlock.formatDuration(workout.totalSeconds)}',
          scheduledDate: nextInstance(day, reminder.hour, reminder.minute),
          notificationDetails: details,
          // Inexact: no special "alarms" permission needed; a delay of a few
          // minutes is fine for a training reminder.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: '$payloadPrefix${workout.id}',
        );
      } catch (e) {
        debugPrint('[ELAND] reminder scheduling failed: $e');
      }
    }
  }

  @override
  Future<void> cancel(String workoutId) async {
    for (var day = 1; day <= 7; day++) {
      await _plugin.cancel(id: notificationIdFor(workoutId, day));
    }
  }

  @override
  Future<void> rescheduleAll(List<CustomWorkout> workouts) async {
    await initialize();
    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      if (request.id >= _firstReminderId) {
        await _plugin.cancel(id: request.id);
      }
    }
    for (final workout in workouts) {
      await schedule(workout);
    }
  }
}
