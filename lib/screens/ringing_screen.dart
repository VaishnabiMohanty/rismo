import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/alarm_model.dart';
import '../providers/alarm_provider.dart';
import '../providers/streak_provider.dart';
import '../services/alarm_service.dart';
import '../providers/todo_provider.dart';

class RingingScreen extends ConsumerWidget {
  final AlarmModel alarm;
  const RingingScreen({super.key, required this.alarm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? const Color(0xFF0A1628)
        : Theme.of(context).colorScheme.primary;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // ── Time ────────────────────────────────────────────────
                  Text(
                    alarm.timeLabelAmPm,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                      letterSpacing: -2,
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

                  const SizedBox(height: 12),

                  Text(
                    alarm.label.isEmpty ? 'Wake up! ☀️' : alarm.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.85),
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const Spacer(flex: 1),

                  // ── Pulsing alarm icon ──────────────────────────────────
                  Icon(
                    Icons.alarm_rounded,
                    size: 110,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withValues(alpha: 0.9),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.15, 1.15),
                    duration: 800.ms,
                    curve: Curves.easeInOut,
                  )
                      .then()
                      .scale(
                    begin: const Offset(1.15, 1.15),
                    end: const Offset(1, 1),
                    duration: 800.ms,
                    curve: Curves.easeInOut,
                  ),

                  const Spacer(flex: 1),

                  // ── Dismiss ─────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () => _dismiss(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Theme.of(context).colorScheme.onPrimary,
                        foregroundColor:
                        Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: const Text(
                        'Dismiss',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 16),

                  // ── Snooze ──────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => _snooze(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                        Theme.of(context).colorScheme.onPrimary,
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.6),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Text(
                        'Snooze ${alarm.snoozeDuration} min',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _dismiss(BuildContext context, WidgetRef ref) async {
    await AlarmService.dismissAlarm(alarm);
    await ref.read(streakNotifierProvider.notifier).recordWake();
    await ref.read(alarmProvider.notifier).incrementStreak(alarm.id);

    if (context.mounted) {
      // Navigate home, then show today's todo sheet
      context.go('/');
      Future.delayed(const Duration(milliseconds: 400), () {
        if (context.mounted) {
          _showTodayTasks(context, ref);
        }
      });
    }
  }

  Future<void> _snooze(BuildContext context, WidgetRef ref) async {
    await AlarmService.snoozeAlarm(alarm);
    if (context.mounted) context.go('/');
  }

  void _showTodayTasks(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TodayTasksSheet(alarmId: alarm.id),
    );
  }
}

// ── Today Tasks bottom sheet shown after dismissing alarm ────────────────────
class _TodayTasksSheet extends ConsumerWidget {
  final String alarmId;
  const _TodayTasksSheet({required this.alarmId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todoProvider(alarmId));
    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: cs.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.checklist_rounded, color: cs.primary),
                  const SizedBox(width: 10),
                  Text(
                    "Today's Tasks",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Close'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: tasksAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 48,
                              color: cs.onSurface.withValues(alpha: 0.2)),
                          const SizedBox(height: 12),
                          Text('No tasks for today',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.4),
                              )),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final task = tasks[i];
                      return _TaskTile(
                        task: task,
                        onToggle: () => ref
                            .read(todoProvider(alarmId).notifier)
                            .toggleTask(task.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final TodoTask task;
  final VoidCallback onToggle;
  const _TaskTile({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: task.isDone
              ? cs.primary.withValues(alpha: 0.08)
              : cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: task.isDone
                ? cs.primary.withValues(alpha: 0.3)
                : cs.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              task.isDone
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: task.isDone ? cs.primary : cs.onSurface.withValues(alpha: 0.4),
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 15,
                  decoration:
                  task.isDone ? TextDecoration.lineThrough : null,
                  color: task.isDone
                      ? cs.onSurface.withValues(alpha: 0.45)
                      : cs.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}