import 'package:just_audio/just_audio.dart';

class AudioService {
  static AudioPlayer? _player;

  // ── Play ─────────────────────────────────────────────────────────────────────

  /// Plays the alarm sound from assets
  /// soundPath e.g. "assets/sounds/default_alarm.mp3"
  static Future<void> playAlarm(String soundPath) async {
    _player = AudioPlayer();

    await _player!.setAsset(soundPath);
    await _player!.setLoopMode(LoopMode.one); // loops until dismissed
    await _player!.setVolume(0.3);   // start soft

    await _player!.play();

    // Crescendo — gradually increase volume over 30 seconds
    _crescendo();
  }

  // ── Stop ─────────────────────────────────────────────────────────────────────

  static Future<void> stopAlarm() async {
    await _player?.stop();
    await _player?.dispose();
    _player = null;
  }

  // ── Crescendo ────────────────────────────────────────────────────────────────

  /// Gradually increases volume from 0.3 to 1.0 over 30 seconds
  /// Much less jarring than a sudden loud alarm
  static void _crescendo() async {
    if (_player == null) return;

    const steps = 14;
    const stepDuration = Duration(seconds: 2);
    const minVolume = 0.3;
    const maxVolume = 1.0;
    const volumeStep = (maxVolume - minVolume) / steps;

    double volume = minVolume;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(stepDuration);
      if (_player == null) return; // stopped before crescendo finished
      volume = (volume + volumeStep).clamp(minVolume, maxVolume);
      await _player!.setVolume(volume);
    }
  }

  // ── State ────────────────────────────────────────────────────────────────────

  static bool get isPlaying => _player?.playing ?? false;
}