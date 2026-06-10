import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StreakBadge extends StatelessWidget {
  final int currentStreak;
  final int bestStreak;

  const StreakBadge({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: currentStreak > 0
              ? [Colors.orange.shade400, Colors.deepOrange.shade500]
              : [colorScheme.surfaceContainerHighest, colorScheme.surfaceContainerHighest],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // ── Flame icon ───────────────────────────────────────────────────
          Text(
            currentStreak > 0 ? '🔥' : '💤',
            style: const TextStyle(fontSize: 36),
          )
              .animate(
            onPlay: (c) => currentStreak > 0 ? c.repeat() : null,
          )
              .then(delay: 1200.ms)
              .shimmer(duration: 800.ms, color: Colors.yellow.withValues(alpha: 0.6)),

          const SizedBox(width: 16),

          // ── Streak info ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentStreak == 0
                      ? 'Start your streak!'
                      : '$currentStreak day streak',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: currentStreak > 0
                        ? Colors.white
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentStreak == 0
                      ? 'Dismiss an alarm on time to begin'
                      : 'Best: $bestStreak days 🏆',
                  style: TextStyle(
                    fontSize: 13,
                    color: currentStreak > 0
                        ? Colors.white.withValues(alpha: 0.8)
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // ── Next milestone ───────────────────────────────────────────────
          if (currentStreak > 0)
            _NextMilestone(currentStreak: currentStreak),
        ],
      ),
    );
  }
}

class _NextMilestone extends StatelessWidget {
  final int currentStreak;

  const _NextMilestone({required this.currentStreak});

  int get _nextMilestone {
    const milestones = [1, 3, 5, 7, 14, 21, 30, 50, 100];
    return milestones.firstWhere(
          (m) => m > currentStreak,
      orElse: () => currentStreak + 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = _nextMilestone - currentStreak;

    return Column(
      children: [
        Text(
          '$daysLeft',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          daysLeft == 1 ? 'day to\nnext 🏆' : 'days to\nnext 🏆',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}