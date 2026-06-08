import 'package:permission_handler/permission_handler.dart';

class PermissionService {

  /// Call this on first launch — requests all permissions at once
  static Future<void> requestAllPermissions() async {
    // Basic permissions
    await [
      Permission.notification,
      Permission.scheduleExactAlarm,
      Permission.camera,
    ].request();

    // Battery optimization — separate request needed
    // This is CRITICAL on Samsung — without it alarms die in background
    if (!await Permission.ignoreBatteryOptimizations.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  // ── Individual checks ─────────────────────────────────────────────────────

  static Future<bool> isNotificationGranted() async =>
      await Permission.notification.isGranted;

  static Future<bool> isExactAlarmGranted() async =>
      await Permission.scheduleExactAlarm.isGranted;

  static Future<bool> isBatteryOptimizationIgnored() async =>
      await Permission.ignoreBatteryOptimizations.isGranted;

  // ── Open settings if permanently denied ──────────────────────────────────

  static Future<void> openSettings() async =>
      await openAppSettings();
}