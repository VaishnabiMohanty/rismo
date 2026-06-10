import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Highest streak ever achieved
final bestStreakProvider = FutureProvider<int>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('best_streak') ?? 0;
});

// Whether to show the mascot popup
final showMascotProvider = StateProvider<bool>((ref) => false);

// The line the mascot will say
final mascotLineProvider = StateProvider<String>((ref) => '');

// Main streak notifier
final streakNotifierProvider =
AsyncNotifierProvider<StreakNotifier, StreakState>(StreakNotifier.new);

class StreakState {
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastWakeTime;
  final List<DateTime> wakeHistory; // last 30 days

  const StreakState({
    required this.currentStreak,
    required this.bestStreak,
    this.lastWakeTime,
    required this.wakeHistory,
  });

  StreakState copyWith({
    int? currentStreak,
    int? bestStreak,
    DateTime? lastWakeTime,
    List<DateTime>? wakeHistory,
  }) {
    return StreakState(
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastWakeTime: lastWakeTime ?? this.lastWakeTime,
      wakeHistory: wakeHistory ?? this.wakeHistory,
    );
  }
}

class StreakNotifier extends AsyncNotifier<StreakState> {
  @override
  Future<StreakState> build() async {
    final prefs = await SharedPreferences.getInstance();

    final currentStreak = prefs.getInt('current_streak') ?? 0;
    final bestStreak = prefs.getInt('best_streak') ?? 0;
    final lastWakeMs = prefs.getInt('last_wake_time');
    final historyMs = prefs.getStringList('wake_history') ?? [];

    return StreakState(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      lastWakeTime:
      lastWakeMs != null ? DateTime.fromMillisecondsSinceEpoch(lastWakeMs) : null,
      wakeHistory: historyMs
          .map((ms) => DateTime.fromMillisecondsSinceEpoch(int.parse(ms)))
          .toList(),
    );
  }

  // ── Record wake ──────────────────────────────────────────────────────────────

  /// Call this when user dismisses the alarm on time
  Future<void> recordWake() async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.value!;
    final now = DateTime.now();

    // Check if already recorded today
    if (current.lastWakeTime != null &&
        _isSameDay(current.lastWakeTime!, now)) {
      return;
    }

    final newStreak = current.currentStreak + 1;
    final newBest =
    newStreak > current.bestStreak ? newStreak : current.bestStreak;

    // Keep only last 30 days of history
    final history = [...current.wakeHistory, now];
    if (history.length > 30) history.removeAt(0);

    // Persist
    await prefs.setInt('current_streak', newStreak);
    await prefs.setInt('best_streak', newBest);
    await prefs.setInt('last_wake_time', now.millisecondsSinceEpoch);
    await prefs.setStringList(
      'wake_history',
      history.map((d) => d.millisecondsSinceEpoch.toString()).toList(),
    );

    state = AsyncData(current.copyWith(
      currentStreak: newStreak,
      bestStreak: newBest,
      lastWakeTime: now,
      wakeHistory: history,
    ));

    // Trigger mascot popup on milestone streaks
    _checkMascotTrigger(newStreak);
  }

  // ── Reset streak ─────────────────────────────────────────────────────────────

  /// Call this when user misses an alarm
  Future<void> resetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.value!;

    await prefs.setInt('current_streak', 0);

    state = AsyncData(current.copyWith(currentStreak: 0));
  }

  // ── Mascot trigger ───────────────────────────────────────────────────────────

  void _checkMascotTrigger(int streak) {
    // Always show mascot when waking — robot should say something every time
    ref.read(showMascotProvider.notifier).state = true;
  }

  // ── Helper ───────────────────────────────────────────────────────────────────

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}