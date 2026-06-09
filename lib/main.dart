import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'providers/alarm_provider.dart';
import 'services/notification_service.dart';
import 'services/permission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  // Initialize the new alarm plugin
  await Alarm.init();

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

class RismoApp extends ConsumerStatefulWidget {
  const RismoApp({super.key});

  @override
  ConsumerState<RismoApp> createState() => _RismoAppState();
}

class _RismoAppState extends ConsumerState<RismoApp> {
  late StreamSubscription<AlarmSet> _ringSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for alarms ringing
    _ringSubscription = Alarm.ringing.listen(_handleAlarmRing);
  }

  @override
  void dispose() {
    _ringSubscription.cancel();
    super.dispose();
  }

  void _handleAlarmRing(AlarmSet set) async {
    if (set.alarms.isEmpty) return;

    // When an alarm rings, find the model and navigate to RingingScreen
    // In v5, ringing emits the whole set of ringing alarms
    final settings = set.alarms.first;
    
    final alarms = await ref.read(alarmProvider.future);
    final alarm = alarms.firstWhere(
      (a) => a.id.hashCode == settings.id,
      orElse: () => alarms.first, // fallback
    );

    if (mounted) {
      final router = ref.read(appRouterProvider);
      // Only go to ringing if not already there (or check if it's a new alarm)
      router.push('/ringing', extra: alarm);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final settingsAsync = ref.watch(settingsProvider);

    final themeMode = settingsAsync.when(
      data: (s) => s.themeMode,
      loading: () => ThemeMode.system,
      error: (_, __) => ThemeMode.system,
    );

    return MaterialApp.router(
      title: 'Rismo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
