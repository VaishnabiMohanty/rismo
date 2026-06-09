import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/alarm_model.dart';

class AlarmTile extends StatelessWidget {
  final AlarmModel alarm;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AlarmTile({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = alarm.isEnabled;
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(alarm.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: isEnabled
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isEnabled
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              // ── Left: time & label ─────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time
                    Text(
                      alarm.timeLabelAmPm,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isEnabled
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Label
                    if (alarm.label.isNotEmpty)
                      Text(
                        alarm.label,
                        style: TextStyle(
                          fontSize: 14,
                          color: isEnabled
                              ? colorScheme.onPrimaryContainer.withValues(alpha: 0.75)
                              : colorScheme.onSurface.withValues(alpha: 0.35),
                        ),
                      ),

                    const SizedBox(height: 6),

                    // Repeat days & streak
                    Row(
                      children: [
                        Icon(
                          Icons.repeat,
                          size: 13,
                          color: isEnabled
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          alarm.repeatLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: isEnabled
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                        if (alarm.streakCount > 0) ...[
                          const SizedBox(width: 12),
                          Text(
                            '🔥 ${alarm.streakCount}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── Right: toggle ──────────────────────────────────────────────
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeThumbColor: colorScheme.primary,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05),
      ),
    );
  }
}