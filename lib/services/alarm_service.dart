import 'package:alarm/alarm.dart';
import '../models/alarm_model.dart';
import 'notification_service.dart';

class AlarmService {
  // ── Schedule ─────────────────────────────────────────────────────────────────

  /// Schedules an alarm using the modern alarm plugin
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

    final alarmSettings = AlarmSettings(
      id: alarm.id.hashCode,
      dateTime: alarmTime,
      assetAudioPath: alarm.soundPath,
      notificationSettings: NotificationSettings(
        title: 'Rismo ⏰',
        body: alarm.label.isEmpty ? 'Time to wake up!' : alarm.label,
        stopButton: 'Dismiss',
      ),
      volumeSettings: VolumeSettings.fade(
        volume: 0.5,
        fadeDuration: const Duration(seconds: 30),
      ),
      loopAudio: true,
      vibrate: true,
      androidFullScreenIntent: true,
    );

    await Alarm.set(alarmSettings: alarmSettings);

    // We still keep the local notification for the "Next Alarm" status 
    // and manual cancellation if needed, though 'alarm' handles the ringing.
    await NotificationService.scheduleAlarmNotification(alarm);
  }

  // ── Cancel ───────────────────────────────────────────────────────────────────

  /// Cancels both the alarm trigger and its notification
  static Future<void> cancelAlarm(AlarmModel alarm) async {
    await Alarm.stop(alarm.id.hashCode);
    await NotificationService.cancelAlarmNotification(alarm.id);
  }

  // ── Snooze ───────────────────────────────────────────────────────────────────

  /// Cancels current alarm and reschedules after snooze duration
  static Future<void> snoozeAlarm(AlarmModel alarm) async {
    await Alarm.stop(alarm.id.hashCode);
    await NotificationService.cancelAlarmNotification(alarm.id);

    final snoozeTime = DateTime.now().add(
      Duration(minutes: alarm.snoozeDuration),
    );

    final snoozedAlarm = alarm.copyWith(
      hour: snoozeTime.hour,
      minute: snoozeTime.minute,
      repeatDays: '', // snooze is always one-time
    );

    final snoozeSettings = AlarmSettings(
      id: alarm.id.hashCode,
      dateTime: snoozeTime,
      assetAudioPath: alarm.soundPath,
      notificationSettings: NotificationSettings(
        title: 'Rismo (Snoozed) ⏰',
        body: alarm.label.isEmpty ? 'Time to wake up!' : alarm.label,
        stopButton: 'Dismiss',
      ),
      volumeSettings: VolumeSettings.fade(
        volume: 0.5,
        fadeDuration: const Duration(seconds: 30),
      ),
      loopAudio: true,
      vibrate: true,
      androidFullScreenIntent: true,
    );

    await Alarm.set(alarmSettings: snoozeSettings);
    await NotificationService.scheduleAlarmNotification(snoozedAlarm);
  }

  // ── Dismiss ──────────────────────────────────────────────────────────────────

  /// Stops the alarm sound and cancels notification
  static Future<void> dismissAlarm(AlarmModel alarm) async {
    await Alarm.stop(alarm.id.hashCode);
    await NotificationService.cancelAlarmNotification(alarm.id);

    // If repeating, reschedule for next occurrence automatically
    if (alarm.isRepeating) {
      await scheduleAlarm(alarm);
    }
  }
}
