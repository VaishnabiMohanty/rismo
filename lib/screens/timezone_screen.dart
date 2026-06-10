import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _TzEntry {
  final String city;
  final String region;
  final String tzName;
  final Duration offset;
  const _TzEntry(this.city, this.region, this.tzName, this.offset);
}

class TimezoneScreen extends StatefulWidget {
  const TimezoneScreen({super.key});

  @override
  State<TimezoneScreen> createState() => _TimezoneScreenState();
}

class _TimezoneScreenState extends State<TimezoneScreen> {
  Timer? _timer;
  String _search = '';
  final _searchCtrl = TextEditingController();

  static final List<_TzEntry> _allZones = [
    _TzEntry('New York',     'USA',          'America/New_York',    Duration(hours: -5)),
    _TzEntry('Los Angeles',  'USA',          'America/Los_Angeles', Duration(hours: -8)),
    _TzEntry('Chicago',      'USA',          'America/Chicago',     Duration(hours: -6)),
    _TzEntry('London',       'UK',           'Europe/London',       Duration(hours: 0)),
    _TzEntry('Paris',        'France',       'Europe/Paris',        Duration(hours: 1)),
    _TzEntry('Berlin',       'Germany',      'Europe/Berlin',       Duration(hours: 1)),
    _TzEntry('Moscow',       'Russia',       'Europe/Moscow',       Duration(hours: 3)),
    _TzEntry('Dubai',        'UAE',          'Asia/Dubai',          Duration(hours: 4)),
    _TzEntry('Mumbai',       'India',        'Asia/Kolkata',        Duration(hours: 5, minutes: 30)),
    _TzEntry('Kolkata',      'India',        'Asia/Kolkata',        Duration(hours: 5, minutes: 30)),
    _TzEntry('Dhaka',        'Bangladesh',   'Asia/Dhaka',          Duration(hours: 6)),
    _TzEntry('Bangkok',      'Thailand',     'Asia/Bangkok',        Duration(hours: 7)),
    _TzEntry('Singapore',    'Singapore',    'Asia/Singapore',      Duration(hours: 8)),
    _TzEntry('Beijing',      'China',        'Asia/Shanghai',       Duration(hours: 8)),
    _TzEntry('Tokyo',        'Japan',        'Asia/Tokyo',          Duration(hours: 9)),
    _TzEntry('Seoul',        'South Korea',  'Asia/Seoul',          Duration(hours: 9)),
    _TzEntry('Sydney',       'Australia',    'Australia/Sydney',    Duration(hours: 11)),
    _TzEntry('Auckland',     'New Zealand',  'Pacific/Auckland',    Duration(hours: 13)),
    _TzEntry('Sao Paulo',    'Brazil',       'America/Sao_Paulo',   Duration(hours: -3)),
    _TzEntry('Mexico City',  'Mexico',       'America/Mexico_City', Duration(hours: -6)),
    _TzEntry('Toronto',      'Canada',       'America/Toronto',     Duration(hours: -5)),
    _TzEntry('Cairo',        'Egypt',        'Africa/Cairo',        Duration(hours: 2)),
    _TzEntry('Nairobi',      'Kenya',        'Africa/Nairobi',      Duration(hours: 3)),
    _TzEntry('Johannesburg', 'South Africa', 'Africa/Johannesburg', Duration(hours: 2)),
    _TzEntry('Reykjavik',    'Iceland',      'Atlantic/Reykjavik',  Duration(hours: 0)),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  DateTime _timeFor(_TzEntry tz) {
    return DateTime.now().toUtc().add(tz.offset);
  }

  String _offsetLabel(_TzEntry tz) {
    final h = tz.offset.inHours;
    final m = tz.offset.inMinutes.abs() % 60;
    final sign = h >= 0 ? '+' : '';
    return m == 0 ? 'UTC$sign$h' : 'UTC$sign$h:${m.toString().padLeft(2, '0')}';
  }

  List<_TzEntry> get _filtered {
    if (_search.isEmpty) return _allZones;
    final q = _search.toLowerCase();
    return _allZones
        .where((z) =>
    z.city.toLowerCase().contains(q) ||
        z.region.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final localNow = DateTime.now();
    final fmt12 = DateFormat('h:mm a');
    final fmtDate = DateFormat('EEE, MMM d');

    return Scaffold(
      appBar: AppBar(title: const Text('World Clock')),
      body: Column(
        children: [
          // ── Local time hero ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            color: cs.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Local Time',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onPrimaryContainer.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  fmt12.format(localNow),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: cs.onPrimaryContainer,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  fmtDate.format(localNow),
                  style: TextStyle(
                    color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ── Search ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search city or country...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // ── Zone list ────────────────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final tz = _filtered[i];
                final t = _timeFor(tz);
                final isNight = t.hour < 6 || t.hour >= 22;
                final isEvening = t.hour >= 18 && t.hour < 22;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isNight
                              ? const Color(0xFF1A2A4A)
                              : isEvening
                              ? const Color(0xFFFF6B35).withValues(alpha: 0.15)
                              : cs.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isNight
                              ? Icons.nights_stay_rounded
                              : isEvening
                              ? Icons.wb_twilight_rounded
                              : Icons.wb_sunny_rounded,
                          size: 20,
                          color: isNight
                              ? const Color(0xFF7BA7E0)
                              : isEvening
                              ? const Color(0xFFFF6B35)
                              : cs.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tz.city,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            Text(
                              '${tz.region} · ${_offsetLabel(tz)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            fmt12.format(t),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: cs.primary,
                            ),
                          ),
                          Text(
                            fmtDate.format(t),
                            style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}