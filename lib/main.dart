import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'services/permission_service.dart';

// Must be top-level for alarm manager to call it
@pragma('vm:entry-point')
void alarmCallback() {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  // Initialize alarm manager — without this alarms never fire
  await AndroidAlarmManager.initialize();

  await NotificationService.init();

  runApp(
    const ProviderScope(
      child: RismoApp(),
    ),
  );

  // Request all permissions after app is running to prevent startup crashes
  await PermissionService.requestAllPermissions();
  await NotificationService.requestPermission();
}

class RismoApp extends ConsumerWidget {
  const RismoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Watch settings so theme updates LIVE when user changes it
    final settingsAsync = ref.watch(settingsProvider);

    // Default to system while loading
    final themeMode = settingsAsync.when(
      data: (s) => s.themeMode,
      loading: () => ThemeMode.system,
      error: (_, __) => ThemeMode.system,
    );

    return MaterialApp.router(
      title: 'Rismo',
      debugShowCheckedModeBanner: false,

      // Both themes provided — Flutter picks based on themeMode
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, // ← reacts instantly when changed in settings

      routerConfig: router,
    );
  }
}