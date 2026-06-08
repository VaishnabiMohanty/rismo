class AppConstants {
  AppConstants._();

  // ── App info ──────────────────────────────────────────────────────────────

  static const String appName = 'Rismo';
  static const String appVersion = '1.0.0';

  // ── Alarm sounds — all 4 real filenames ──────────────────────────────────

  static const Map<String, String> alarmSounds = {
    'Classic':       'assets/sounds/mixkit-classic-alarm-995.mp3',
    'Digital Buzz':  'assets/sounds/mixkit-digital-clock-digital-alarm-buzzer-992.mp3',
    'Morning Clock': 'assets/sounds/mixkit-morning-clock-alarm-1003.mp3',
    'Rooster':       'assets/sounds/mixkit-rooster-crowing-in-the-morning-2462.mp3',
  };

  // ── Snooze options (minutes) ──────────────────────────────────────────────

  static const List<int> snoozeOptions = [5, 10, 15, 20, 30];

  // ── Streak milestones ─────────────────────────────────────────────────────

  static const List<int> streakMilestones = [1, 3, 5, 7, 14, 21, 30, 50, 100];

  // ── Lottie animation paths ────────────────────────────────────────────────

  static const String mascotCelebrate = 'assets/animations/robot.json';
  static const String mascotJump      = 'assets/animations/robot.json';
  static const String mascotWiggle    = 'assets/animations/robot.json';

  // ── SharedPreferences keys ────────────────────────────────────────────────

  static const String keyThemeMode      = 'theme_mode';
  static const String keySnoozeDuration = 'snooze_duration';
  static const String keyDefaultSound   = 'default_sound';
  static const String keyUse24h         = 'use_24h';
  static const String keyUserName       = 'user_name';
  static const String keyAvatarPath     = 'avatar_path';
  static const String keyCurrentStreak  = 'current_streak';
  static const String keyBestStreak     = 'best_streak';
  static const String keyLastWakeTime   = 'last_wake_time';
  static const String keyWakeHistory    = 'wake_history';

  // ── UI constants ──────────────────────────────────────────────────────────

  static const double borderRadius   = 20.0;
  static const double cardPadding    = 16.0;
  static const double screenPadding  = 20.0;
  static const Duration animDuration = Duration(milliseconds: 300);
}