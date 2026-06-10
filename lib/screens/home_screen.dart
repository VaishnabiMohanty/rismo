import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/alarm_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/avatar_provider.dart';
import '../utils/mascot_lines.dart';
import '../widgets/alarm_tile.dart';
import '../widgets/streak_badge.dart';
import '../widgets/mascot_popup.dart';

// Provider to hold the greeting line shown at bottom-left
final _greetingLineProvider = Provider<String>((ref) {
  final streak = ref.watch(streakNotifierProvider).value?.currentStreak ?? 0;
  return MascotLines.combined(streak);
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _mascotExpanded = true;

  @override
  Widget build(BuildContext context) {
    final alarmsAsync = ref.watch(alarmProvider);
    final streakAsync = ref.watch(streakNotifierProvider);
    final avatarPath  = ref.watch(avatarProvider).value;
    final showMascot  = ref.watch(showMascotProvider);
    final greeting    = ref.watch(_greetingLineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rismo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
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
          // ── Main content ─────────────────────────────────────────────────
          alarmsAsync.when(
            loading: () =>
            const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (alarms) {
              return Column(
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
                        ? _EmptyStateWithRobot()
                        : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
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

          // ── Persistent mascot — bottom left ──────────────────────────────
          Positioned(
            left: 0,
            bottom: 80,
            child: _PersistentMascot(
              greeting: greeting,
              expanded: _mascotExpanded,
              onTap: () =>
                  setState(() => _mascotExpanded = !_mascotExpanded),
            ),
          ),

          // ── Mascot streak popup ───────────────────────────────────────────
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
                      ref.read(showMascotProvider.notifier).state = false,
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

// ── Persistent bottom-left mascot widget ─────────────────────────────────────

class _PersistentMascot extends StatelessWidget {
  final String greeting;
  final bool expanded;
  final VoidCallback onTap;

  const _PersistentMascot({
    required this.greeting,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Robot
          SizedBox(
            width: 80,
            height: 80,
            child: Lottie.asset(
              'assets/animations/robot.json',
              repeat: true,
              animate: true,
            ),
          ),

          // Speech bubble
          if (expanded)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 110,
              ),
              child: Container(
                margin: const EdgeInsets.only(left: 6, bottom: 20),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onPrimaryContainer,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),
            ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyStateWithRobot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/animations/robot.json',
          height: 200,
          repeat: true,
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