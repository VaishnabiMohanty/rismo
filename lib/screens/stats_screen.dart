import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/streak_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Stats')),
      body: streakAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (streak) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Stat cards row ───────────────────────────────────────────────
            Row(
              children: [
                _StatCard(
                  label: 'Current Streak',
                  value: '${streak.currentStreak}',
                  unit: 'days',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Best Streak',
                  value: '${streak.bestStreak}',
                  unit: 'days',
                  icon: Icons.emoji_events,
                  color: Colors.amber,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(
                  label: 'Total Wakes',
                  value: '${streak.wakeHistory.length}',
                  unit: 'times',
                  icon: Icons.alarm_on,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Last Wake',
                  value: streak.lastWakeTime != null
                      ? DateFormat('MMM d').format(streak.lastWakeTime!)
                      : '—',
                  unit: streak.lastWakeTime != null
                      ? DateFormat('h:mm a').format(streak.lastWakeTime!)
                      : '',
                  icon: Icons.schedule,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Milestone progress ───────────────────────────────────────────
            Text(
              'Milestones',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...[1, 3, 5, 7, 14, 21, 30, 50, 100].map(
                  (milestone) => _MilestoneTile(
                milestone: milestone,
                achieved: streak.currentStreak >= milestone,
              ),
            ),
            const SizedBox(height: 28),

            // ── Wake history ─────────────────────────────────────────────────
            Text(
              'Wake History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (streak.wakeHistory.isEmpty)
              Text(
                'No wake history yet. Dismiss your first alarm to start tracking!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.5),
                ),
              )
            else
              ...streak.wakeHistory.reversed.map(
                    (dt) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(DateFormat('EEEE, MMM d').format(dt)),
                  trailing: Text(
                    DateFormat('h:mm a').format(dt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Stat card widget ──────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              unit,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Milestone tile ────────────────────────────────────────────────────────────

class _MilestoneTile extends StatelessWidget {
  final int milestone;
  final bool achieved;

  const _MilestoneTile({required this.milestone, required this.achieved});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor:
        achieved ? Colors.green : Colors.grey.withOpacity(0.2),
        child: Icon(
          achieved ? Icons.check : Icons.lock_outline,
          size: 16,
          color: achieved ? Colors.white : Colors.grey,
        ),
      ),
      title: Text(
        '$milestone day streak',
        style: TextStyle(
          color: achieved
              ? Theme.of(context).colorScheme.onBackground
              : Theme.of(context).colorScheme.onBackground.withOpacity(0.4),
          fontWeight: achieved ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: achieved
          ? const Text('🏆', style: TextStyle(fontSize: 18))
          : null,
    );
  }
}