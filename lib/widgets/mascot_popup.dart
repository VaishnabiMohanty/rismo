import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/streak_provider.dart';
import '../utils/mascot_lines.dart';

enum MascotOccasion { achievement, streakContinue, motivation }

class MascotPopup extends ConsumerStatefulWidget {
  final VoidCallback onDismiss;
  const MascotPopup({super.key, required this.onDismiss});

  @override
  ConsumerState<MascotPopup> createState() => _MascotPopupState();
}

class _MascotPopupState extends ConsumerState<MascotPopup>
    with SingleTickerProviderStateMixin {
  late String _line;
  late MascotOccasion _occasion;
  late AnimationController _lottieController;

  static const _milestones = {1, 3, 5, 7, 14, 21, 30, 50, 100};

  static bool get _isMotivationDay {
    final w = DateTime.now().weekday;
    return w == 1 || w == 5;
  }

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(vsync: this);

    final streak = ref.read(streakNotifierProvider).value?.currentStreak ?? 0;

    if (_milestones.contains(streak)) {
      _occasion = MascotOccasion.achievement;
    } else if (_isMotivationDay) {
      _occasion = MascotOccasion.motivation;
    } else {
      _occasion = MascotOccasion.streakContinue;
    }

    _line = MascotLines.combined(streak);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  // ── Per-occasion config ───────────────────────────────────────────────────

  String get _occasionTitle {
    switch (_occasion) {
      case MascotOccasion.achievement:    return 'Achievement Unlocked! 🏆';
      case MascotOccasion.streakContinue: return 'Streak Continues! 🔥';
      case MascotOccasion.motivation:     return 'Keep Going! 💪';
    }
  }

  Color get _occasionColor {
    switch (_occasion) {
      case MascotOccasion.achievement:    return Colors.amber.shade600;
      case MascotOccasion.streakContinue: return Colors.orange.shade500;
      case MascotOccasion.motivation:     return Colors.deepPurple.shade400;
    }
  }

  String get _buttonLabel {
    switch (_occasion) {
      case MascotOccasion.achievement:    return 'Claim it! 🏆';
      case MascotOccasion.streakContinue: return "Let's go! 🔥";
      case MascotOccasion.motivation:     return "I'm ready! 💪";
    }
  }

  // Speed multiplier — faster = more excited
  // achievement: fast & excited, motivation: medium wiggle, continue: normal
  double get _animationSpeed {
    switch (_occasion) {
      case MascotOccasion.achievement:    return 1.8; // fast celebrate
      case MascotOccasion.streakContinue: return 1.2; // slightly bouncy
      case MascotOccasion.motivation:     return 0.8; // slow wriggle
    }
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(streakNotifierProvider).value?.currentStreak ?? 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──────────────────────────────────────────────────
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ── Occasion title ───────────────────────────────────────────────
          Text(
            _occasionTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _occasionColor,
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

          const SizedBox(height: 4),
          Text(
            '$streak day streak',
            style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.5)),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 8),

          // ── Robot mascot — same robot.json, speed changes per occasion ───
          Animate(
            effects: const [
              ScaleEffect(
                begin: Offset(0.5, 0.5),
                end: Offset(1.0, 1.0),
                duration: Duration(milliseconds: 500),
                curve: Curves.elasticOut,
              ),
            ],
            child: Lottie.asset(
              'assets/animations/robot.json',
              controller: _lottieController,
              height: 160,
              onLoaded: (composition) {
                final ms = composition.duration.inMilliseconds;
                final speed = _animationSpeed;
                _lottieController.duration =
                    Duration(milliseconds: (ms / speed).round());
                _lottieController.repeat();
              },
            ),
          ),

          const SizedBox(height: 12),

          // ── Speech bubble ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _occasionColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border:
              Border.all(color: _occasionColor.withOpacity(0.25)),
            ),
            child: Text(
              _line,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.15),

          const SizedBox(height: 20),

          // ── Button ───────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: _occasionColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _buttonLabel,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}