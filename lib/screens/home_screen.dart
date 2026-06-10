import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../providers/alarm_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/avatar_provider.dart';
import '../widgets/alarm_tile.dart';
import '../widgets/streak_badge.dart';
import '../widgets/mascot_popup.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmsAsync  = ref.watch(alarmProvider);
    final streakAsync  = ref.watch(streakNotifierProvider);
    final avatarPath   = ref.watch(avatarProvider).value;
    final showMascot   = ref.watch(showMascotProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Rismo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: avatarPath != null
                    ? FileImage(File(avatarPath))
                    : null,
                child: avatarPath == null
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: alarmsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (alarms) {
          return Column(
            children: [
              // ── Streak badge ─────────────────────────────────────────────
              streakAsync.when(
                data: (streak) => StreakBadge(
                  currentStreak: streak.currentStreak,
                  bestStreak: streak.bestStreak,
                ),
                loading: () => const SizedBox(height: 80),
                error: (_, __) => const SizedBox(),
              ),

              // ── Alarm list or empty state with robot ─────────────────────
              Expanded(
                child: alarms.isEmpty
                    ? _EmptyStateWithRobot()
                    : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: alarms.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final alarm = alarms[index];
                    return AlarmTile(
                      alarm: alarm,
                      onToggle: (val) => ref
                          .read(alarmProvider.notifier)
                          .toggleAlarm(alarm.id, val),
                      onTap: () =>
                          context.push('/add-edit', extra: alarm),
                      onDelete: () => ref
                          .read(alarmProvider.notifier)
                          .deleteAlarm(alarm.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-edit'),
        icon: const Icon(Icons.add),
        label: const Text('New Alarm'),
      ),

      // ── Mascot popup — appears on streak milestones ───────────────────────
      bottomSheet: showMascot
          ? MascotPopup(
        onDismiss: () =>
        ref.read(showMascotProvider.notifier).state = false,
      )
          : null,
    );
  }
}

// ── Empty state: robot sits here when no alarms are set ──────────────────────

class _EmptyStateWithRobot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Robot plays its default animation idly
        Lottie.asset(
          'assets/animations/robot.json',
          height: 220,
          repeat: true,   // loops the default animation continuously
          animate: true,
        ),
        const SizedBox(height: 16),
        Text(
          'No alarms yet',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap + to set your first alarm',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }
}