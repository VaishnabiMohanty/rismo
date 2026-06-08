import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/alarm_model.dart';
import '../providers/alarm_provider.dart';
import '../providers/streak_provider.dart';
import '../services/alarm_service.dart';

class RingingScreen extends ConsumerWidget {
  final AlarmModel alarm;

  const RingingScreen({super.key, required this.alarm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false, // prevent back button dismissing without action
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Top: time & label ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Text(
                      alarm.timeLabelAmPm,
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                    const SizedBox(height: 12),
                    Text(
                      alarm.label.isEmpty ? 'Wake up!' : alarm.label,
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.85),
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),

              // ── Middle: pulsing alarm icon ──────────────────────────────────
              Icon(
                Icons.alarm,
                size: 120,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
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

              // ── Bottom: Dismiss & Snooze buttons ────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  children: [
                    // Dismiss
                    ElevatedButton(
                      onPressed: () => _dismiss(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Theme.of(context).colorScheme.onPrimary,
                        foregroundColor:
                        Theme.of(context).colorScheme.primary,
                        minimumSize: const Size(220, 56),
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
                    const SizedBox(height: 16),

                    // Snooze
                    OutlinedButton(
                      onPressed: () => _snooze(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                        Theme.of(context).colorScheme.onPrimary,
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withOpacity(0.6),
                        ),
                        minimumSize: const Size(220, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Text(
                        'Snooze ${alarm.snoozeDuration} min',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _dismiss(BuildContext context, WidgetRef ref) async {
    await AlarmService.dismissAlarm(alarm);

    // Record wake and increment streak
    await ref.read(streakNotifierProvider.notifier).recordWake();
    await ref.read(alarmProvider.notifier).incrementStreak(alarm.id);

    if (context.mounted) context.go('/');
  }

  Future<void> _snooze(BuildContext context, WidgetRef ref) async {
    await AlarmService.snoozeAlarm(alarm);
    if (context.mounted) context.go('/');
  }
}