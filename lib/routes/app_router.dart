import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/alarm_model.dart';
import '../screens/home_screen.dart';
import '../screens/add_edit_screen.dart';
import '../screens/ringing_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/stopwatch_screen.dart';
import '../screens/todo_screen.dart';
import '../screens/calendar_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(path: '/', name: 'home',
          builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/add-edit', name: 'addEdit',
          builder: (c, s) => AddEditScreen(existing: s.extra as AlarmModel?)),
      GoRoute(path: '/ringing', name: 'ringing',
          builder: (c, s) => RingingScreen(alarm: s.extra as AlarmModel)),
      GoRoute(path: '/stats', name: 'stats',
          builder: (c, s) => const StatsScreen()),
      GoRoute(path: '/settings', name: 'settings',
          builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/profile', name: 'profile',
          builder: (c, s) => const ProfileScreen()),
      GoRoute(path: '/stopwatch', name: 'stopwatch',
          builder: (c, s) => const StopwatchScreen()),
      GoRoute(path: '/timezone', name: 'timezone',
          builder: (c, s) => const _TimezoneScreen()),
      GoRoute(path: '/todo', name: 'todo',
          builder: (c, s) => const TodoScreen()),
      GoRoute(path: '/calendar', name: 'calendar',
          builder: (c, s) => const CalendarScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found',
                style: Theme.of(context).textTheme.titleMedium),
            TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home')),
          ],
        ),
      ),
    ),
  );
});

extension AppRoutes on BuildContext {
  void goHome() => go('/');
  void goAddAlarm() => push('/add-edit');
  void goEditAlarm(AlarmModel alarm) => push('/add-edit', extra: alarm);
  void goRinging(AlarmModel alarm) => go('/ringing', extra: alarm);
  void goStats() => push('/stats');
  void goSettings() => push('/settings');
  void goProfile() => push('/profile');
}

// ═══════════════════════════════════════════════════════════════════════════
// TimezoneScreen — inlined to avoid Windows file-path issues
// ═══════════════════════════════════════════════════════════════════════════

class _TzEntry {
  final String city, region;
  final Duration offset;
  const _TzEntry(this.city, this.region, this.offset);
}

class _TimezoneScreen extends StatefulWidget {
  const _TimezoneScreen();
  @override
  State<_TimezoneScreen> createState() => _TimezoneScreenState();
}

class _TimezoneScreenState extends State<_TimezoneScreen> {
  Timer? _timer;
  String _search = '';
  final _ctrl = TextEditingController();

  static final List<_TzEntry> _zones = [
    _TzEntry('New York',    'USA',          const Duration(hours: -5)),
    _TzEntry('Los Angeles', 'USA',          const Duration(hours: -8)),
    _TzEntry('Chicago',     'USA',          const Duration(hours: -6)),
    _TzEntry('London',      'UK',           Duration.zero),
    _TzEntry('Paris',       'France',       const Duration(hours: 1)),
    _TzEntry('Berlin',      'Germany',      const Duration(hours: 1)),
    _TzEntry('Moscow',      'Russia',       const Duration(hours: 3)),
    _TzEntry('Dubai',       'UAE',          const Duration(hours: 4)),
    _TzEntry('Mumbai',      'India',        const Duration(hours: 5, minutes: 30)),
    _TzEntry('Kolkata',     'India',        const Duration(hours: 5, minutes: 30)),
    _TzEntry('Dhaka',       'Bangladesh',   const Duration(hours: 6)),
    _TzEntry('Bangkok',     'Thailand',     const Duration(hours: 7)),
    _TzEntry('Singapore',   'Singapore',    const Duration(hours: 8)),
    _TzEntry('Beijing',     'China',        const Duration(hours: 8)),
    _TzEntry('Tokyo',       'Japan',        const Duration(hours: 9)),
    _TzEntry('Seoul',       'South Korea',  const Duration(hours: 9)),
    _TzEntry('Sydney',      'Australia',    const Duration(hours: 11)),
    _TzEntry('Auckland',    'New Zealand',  const Duration(hours: 13)),
    _TzEntry('Sao Paulo',   'Brazil',       const Duration(hours: -3)),
    _TzEntry('Mexico City', 'Mexico',       const Duration(hours: -6)),
    _TzEntry('Toronto',     'Canada',       const Duration(hours: -5)),
    _TzEntry('Cairo',       'Egypt',        const Duration(hours: 2)),
    _TzEntry('Nairobi',     'Kenya',        const Duration(hours: 3)),
    _TzEntry('Johannesburg','South Africa', const Duration(hours: 2)),
    _TzEntry('Reykjavik',   'Iceland',      Duration.zero),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
        const Duration(seconds: 1), (_) { if (mounted) setState(() {}); });
  }

  @override
  void dispose() { _timer?.cancel(); _ctrl.dispose(); super.dispose(); }

  DateTime _t(_TzEntry z) => DateTime.now().toUtc().add(z.offset);

  String _off(_TzEntry z) {
    final h = z.offset.inHours;
    final m = z.offset.inMinutes.abs() % 60;
    final s = h >= 0 ? '+' : '';
    return m == 0 ? 'UTC$s$h' : 'UTC$s$h:${m.toString().padLeft(2,'0')}';
  }

  List<_TzEntry> get _filtered {
    if (_search.isEmpty) return _zones;
    final q = _search.toLowerCase();
    return _zones.where((z) =>
    z.city.toLowerCase().contains(q) ||
        z.region.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final fmt12 = DateFormat('h:mm a');
    final fmtD  = DateFormat('EEE, MMM d');

    return Scaffold(
      appBar: AppBar(title: const Text('World Clock')),
      body: Column(
        children: [
          // Local time hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            color: cs.primaryContainer,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Your Local Time',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600)),
              Text(fmt12.format(now),
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.w300,
                      color: cs.onPrimaryContainer, letterSpacing: 1)),
              Text(fmtD.format(now),
                  style: TextStyle(color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                      fontSize: 13)),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _ctrl,
              decoration: const InputDecoration(
                hintText: 'Search city or country...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final z = _filtered[i];
                final t = _t(z);
                final isNight = t.hour < 6 || t.hour >= 22;
                final isEvening = t.hour >= 18 && t.hour < 22;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: isNight ? const Color(0xFF1A2A4A)
                            : isEvening ? const Color(0xFFFF6B35).withValues(alpha: 0.15)
                            : cs.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isNight ? Icons.nights_stay_rounded
                            : isEvening ? Icons.wb_twilight_rounded
                            : Icons.wb_sunny_rounded,
                        size: 20,
                        color: isNight ? const Color(0xFF7BA7E0)
                            : isEvening ? const Color(0xFFFF6B35)
                            : cs.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(z.city,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text('${z.region} · ${_off(z)}',
                            style: TextStyle(fontSize: 12,
                                color: cs.onSurface.withValues(alpha: 0.45))),
                      ],
                    )),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(fmt12.format(t),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                              color: cs.primary)),
                      Text(fmtD.format(t),
                          style: TextStyle(fontSize: 11,
                              color: cs.onSurface.withValues(alpha: 0.4))),
                    ]),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}