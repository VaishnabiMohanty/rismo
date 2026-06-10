import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/alarm_model.dart';
import '../screens/home_screen.dart';
import '../screens/add_edit_screen.dart';
import '../screens/ringing_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/stopwatch_screen.dart';
import '../screens/timezone_screen.dart';
import '../screens/todo_screen.dart';

// Riverpod provider so any widget can access the router
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      // ── Home ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // ── Add / Edit alarm ──────────────────────────────────────────────────
      // Pass an existing AlarmModel via `extra` to enter edit mode
      // Pass nothing (or null) to create a new alarm
      GoRoute(
        path: '/add-edit',
        name: 'addEdit',
        builder: (context, state) {
          final alarm = state.extra as AlarmModel?;
          return AddEditScreen(existing: alarm);
        },
      ),

      // ── Ringing screen ────────────────────────────────────────────────────
      // Always pass the AlarmModel via `extra`
      GoRoute(
        path: '/ringing',
        name: 'ringing',
        builder: (context, state) {
          final alarm = state.extra as AlarmModel;
          return RingingScreen(alarm: alarm);
        },
      ),

      // ── Stats ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/stats',
        name: 'stats',
        builder: (context, state) => const StatsScreen(),
      ),

      // ── Settings ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // ── Profile ───────────────────────────────────────────────────────────
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      GoRoute(
        path: '/stopwatch',
        name: 'stopwatch',
        builder: (context, state) => const StopwatchScreen(),
      ),

      GoRoute(
        path: '/timezone',
        name: 'timezone',
        builder: (context, state) => const TimezoneScreen(),
      ),

      GoRoute(
        path: '/todo',
        name: 'todo',
        builder: (context, state) => const TodoScreen(),
      ),
    ],

    // ── Error page ────────────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// ── Navigation helpers ────────────────────────────────────────────────────────
// Use these anywhere instead of typing route strings manually

extension AppRoutes on BuildContext {
  void goHome() => go('/');
  void goAddAlarm() => push('/add-edit');
  void goEditAlarm(AlarmModel alarm) => push('/add-edit', extra: alarm);
  void goRinging(AlarmModel alarm) => go('/ringing', extra: alarm);
  void goStats() => push('/stats');
  void goSettings() => push('/settings');
  void goProfile() => push('/profile');
}