import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';

import '../models/alarm_model.dart';
import 'notification_service.dart';
import 'audio_service.dart';

// Top-level function — required by android_alarm_manager_plus
// Must be outside any class and annotated with @pragma
@pragma('vm:entry-point')
Future<void> onAlarmFired(int id, Map<String, dynamic> params) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Play alarm sound
  await AudioService.playAlarm(params['soundPath'] as String);

  // Show notification on lock screen
  await NotificationService.init();
}

class AlarmService {
  // ── Schedule ─────────────────────────────────────────────────────────────────

  /// Schedules a one-time or repeating alarm
  static Future<void> scheduleAlarm(AlarmModel alarm) async {
    final now = DateTime.now();
    var alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.hour,
      alarm.minute,
    );

    // If time already passed today, push to tomorrow
    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    if (alarm.isRepeating) {
      // Repeating alarm — fires every week on selected days
      await AndroidAlarmManager.periodic(
        const Duration(days: 7),
        alarm.id.hashCode,
        onAlarmFired,
        startAt: alarmTime,
        exact: true,
        wakeup: true, // wakes device from sleep
        rescheduleOnReboot: true, // survives phone restart
        params: {'soundPath': alarm.soundPath},
      );
    } else {
      // One-time alarm
      await AndroidAlarmManager.oneShotAt(
        alarmTime,
        alarm.id.hashCode,
        onAlarmFired,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        params: {'soundPath': alarm.soundPath},
      );
    }

    // Also schedule the visible notification
    await NotificationService.scheduleAlarmNotification(alarm);
  }

  // ── Cancel ───────────────────────────────────────────────────────────────────

  /// Cancels both the alarm trigger and its notification
  static Future<void> cancelAlarm(AlarmModel alarm) async {
    await AndroidAlarmManager.cancel(alarm.id.hashCode);
    await NotificationService.cancelAlarmNotification(alarm.id);
  }

  // ── Snooze ───────────────────────────────────────────────────────────────────

  /// Cancels current alarm and reschedules after snooze duration
  static Future<void> snoozeAlarm(AlarmModel alarm) async {
    // Cancel the currently ringing alarm
    await cancelAlarm(alarm);

    // Schedule a new one-shot alarm after snooze duration
    final snoozeTime = DateTime.now().add(
      Duration(minutes: alarm.snoozeDuration),
    );

    final snoozedAlarm = alarm.copyWith(
      hour: snoozeTime.hour,
      minute: snoozeTime.minute,
      repeatDays: '', // snooze is always one-time
    );

    await AndroidAlarmManager.oneShotAt(
      snoozeTime,
      alarm.id.hashCode,
      onAlarmFired,
      exact: true,
      wakeup: true,
      params: {'soundPath': alarm.soundPath},
    );

    await NotificationService.scheduleAlarmNotification(snoozedAlarm);
  }

  // ── Dismiss ──────────────────────────────────────────────────────────────────

  /// Stops the alarm sound and cancels notification
  static Future<void> dismissAlarm(AlarmModel alarm) async {
    await AudioService.stopAlarm();
    await NotificationService.cancelAlarmNotification(alarm.id);

    // If repeating, reschedule for next occurrence automatically
    if (alarm.isRepeating) {
      await scheduleAlarm(alarm);
    }
  }
}