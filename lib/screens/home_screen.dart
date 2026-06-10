import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/alarm_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/avatar_provider.dart';
import '../widgets/alarm_tile.dart';
import '../widgets/streak_badge.dart';
import '../widgets/mascot_popup.dart';
import '../widgets/persistent_mascot.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmsAsync = ref.watch(alarmProvider);
    final streakAsync = ref.watch(streakNotifierProvider);
    final avatarPath  = ref.watch(avatarProvider).value;
    final showMascot  = ref.watch(showMascotProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rismo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Calendar',
            onPressed: () => context.push('/calendar'),
          ),
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            tooltip: 'Stopwatch',
            onPressed: () => context.push('/stopwatch'),
          ),
          IconButton(
            icon: const Icon(Icons.public_rounded),
            tooltip: 'World Clock',
            onPressed: () => context.push('/timezone'),
          ),
          IconButton(
            icon: const Icon(Icons.checklist_rounded),
            tooltip: 'To-Do',
            onPressed: () => context.push('/todo'),
          ),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
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
      body: Stack(
        children: [
          // ── Main ───────────────────────────────────────────────────────
          alarmsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (alarms) => Column(
              children: [
                streakAsync.when(
                  data: (streak) => StreakBadge(
                    currentStreak: streak.currentStreak,
                    bestStreak: streak.bestStreak,
                  ),
                  loading: () => const SizedBox(height: 80),
                  error: (_, __) => const SizedBox(),
                ),
                Expanded(
                  child: alarms.isEmpty
                      ? _EmptyState()
                      : ListView.separated(
                    padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 140),
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
                        onTap: () => context.push('/add-edit',
                            extra: alarm),
                        onDelete: () => ref
                            .read(alarmProvider.notifier)
                            .deleteAlarm(alarm.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Persistent mascot ────────────────────────────────────────
          const Positioned(
            left: 0,
            bottom: 80,
            child: PersistentMascot(context: MascotContext.home),
          ),

          // ── Streak mascot popup ───────────────────────────────────────
          if (showMascot)
            Positioned.fill(
              child: GestureDetector(
                onTap: () =>
                ref.read(showMascotProvider.notifier).state = false,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: MascotPopup(
                      onDismiss: () =>
                      ref.read(showMascotProvider.notifier).state =
                      false,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-edit'),
        icon: const Icon(Icons.add),
        label: const Text('New Alarm'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/animations/robot.json',
            height: 180, repeat: true),
        const SizedBox(height: 16),
        Text('No alarms yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            )),
        const SizedBox(height: 8),
        Text('Tap + to set your first alarm',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.35),
            )),
      ],
    );
  }
}