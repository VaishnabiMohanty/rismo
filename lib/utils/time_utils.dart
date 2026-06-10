class TimeUtils {
  TimeUtils._(); // prevent instantiation

  // ── Formatting ────────────────────────────────────────────────────────────

  /// "07:30"
  static String to24h(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// "7:30 AM" or "7:30 PM"
  static String to12h(int hour, int minute) {
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  /// Formats based on user preference
  static String format(int hour, int minute, {bool use24h = false}) {
    return use24h ? to24h(hour, minute) : to12h(hour, minute);
  }

  // ── Next ring calculation ─────────────────────────────────────────────────

  /// Returns a human-readable string of how long until the alarm fires
  /// e.g. "in 7 hours 30 minutes" or "in 45 minutes"
  static String timeUntilAlarm(int hour, int minute) {
    final now = DateTime.now();
    var alarmTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    final diff = alarmTime.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    if (hours == 0) return 'in $minutes minute${minutes == 1 ? '' : 's'}';
    if (minutes == 0) return 'in $hours hour${hours == 1 ? '' : 's'}';
    return 'in $hours hour${hours == 1 ? '' : 's'} $minutes minute${minutes == 1 ? '' : 's'}';
  }

  /// Returns the next DateTime this alarm will fire, accounting for repeat days
  /// repeatDays: list of ints 1=Mon … 7=Sun, empty = fire tomorrow if passed
  static DateTime nextAlarmDateTime(
      int hour, int minute, List<int> repeatDays) {
    final now = DateTime.now();
    var candidate = DateTime(now.year, now.month, now.day, hour, minute);

    if (repeatDays.isEmpty) {
      // One-time alarm
      if (candidate.isBefore(now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      return candidate;
    }

    // Find next matching weekday (Flutter weekday: Mon=1 … Sun=7)
    for (int i = 0; i <= 7; i++) {
      final check = candidate.add(Duration(days: i));
      if (check.isBefore(now)) continue;
      if (repeatDays.contains(check.weekday)) return check;
    }

    return candidate.add(const Duration(days: 1));
  }

  // ── Greeting ──────────────────────────────────────────────────────────────

  /// Returns a time-appropriate greeting
  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // ── Day name helpers ──────────────────────────────────────────────────────

  static const _shortDayNames = {
    1: 'Mon', 2: 'Tue', 3: 'Wed',
    4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun',
  };

  static const _fullDayNames = {
    1: 'Monday', 2: 'Tuesday', 3: 'Wednesday',
    4: 'Thursday', 5: 'Friday', 6: 'Saturday', 7: 'Sunday',
  };

  static String shortDayName(int day) => _shortDayNames[day] ?? '';
  static String fullDayName(int day) => _fullDayNames[day] ?? '';

  /// Converts a list of day ints to a readable label
  static String repeatLabel(List<int> days) {
    if (days.isEmpty) return 'One-time';
    if (days.length == 7) return 'Every day';
    if (days.length == 5 && !days.contains(6) && !days.contains(7)) {
      return 'Weekdays';
    }
    if (days.length == 2 && days.contains(6) && days.contains(7)) {
      return 'Weekends';
    }
    return days.map(shortDayName).join(', ');
  }

  // ── Comparison ────────────────────────────────────────────────────────────

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime dt) => isSameDay(dt, DateTime.now());

  static bool isYesterday(DateTime dt) =>
      isSameDay(dt, DateTime.now().subtract(const Duration(days: 1)));
}