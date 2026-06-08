import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../models/alarm_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  // ── Init ────────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request notification permission (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ── Schedule ─────────────────────────────────────────────────────────────────

  /// Schedules a notification for the given alarm
  static Future<void> scheduleAlarmNotification(AlarmModel alarm) async {
    final scheduledTime = _nextAlarmTime(alarm.hour, alarm.minute);

    final androidDetails = AndroidNotificationDetails(
      'alarm_channel', // channel id
      'Alarms', // channel name
      channelDescription: 'AlarMy alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true, // shows even on lock screen
      sound: RawResourceAndroidNotificationSound(
        alarm.soundPath
            .replaceAll('assets/sounds/', '')
            .replaceAll('.mp3', '')
            .replaceAll('-', '_'),
      ),
      playSound: true,
    );

    await _plugin.zonedSchedule(
      id: alarm.id.hashCode,
      title: 'Rismo ⏰',
      body: alarm.label.isEmpty ? 'Time to wake up!' : alarm.label,
      scheduledDate: scheduledTime,
      notificationDetails: NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: alarm.isRepeating
          ? DateTimeComponents.dayOfWeekAndTime
          : null,
    );
  }

  // ── Cancel ───────────────────────────────────────────────────────────────────

  static Future<void> cancelAlarmNotification(String alarmId) async {
    await _plugin.cancel(id: alarmId.hashCode);
  }

  static Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  // ── Tap handler ──────────────────────────────────────────────────────────────

  static void _onNotificationTapped(NotificationResponse response) {
    // Navigate to ringing screen when user taps the notification
    // Navigation is handled via GoRouter in app_router.dart
  }

  // ── Helper ───────────────────────────────────────────────────────────────────

  /// Returns the next TZDateTime for the given hour and minute
  static tz.TZDateTime _nextAlarmTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has already passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}