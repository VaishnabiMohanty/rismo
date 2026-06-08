import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

final settingsProvider =
AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class AppSettings {
  final ThemeMode themeMode;
  final int defaultSnoozeDuration;
  final String defaultSoundPath;
  final bool use24HourFormat;
  final String userName;

  const AppSettings({
    required this.themeMode,
    required this.defaultSnoozeDuration,
    required this.defaultSoundPath,
    required this.use24HourFormat,
    required this.userName,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    int? defaultSnoozeDuration,
    String? defaultSoundPath,
    bool? use24HourFormat,
    String? userName,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      defaultSnoozeDuration: defaultSnoozeDuration ?? this.defaultSnoozeDuration,
      defaultSoundPath: defaultSoundPath ?? this.defaultSoundPath,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      userName: userName ?? this.userName,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeIndex = prefs.getInt(AppConstants.keyThemeMode) ?? 0;

    // Validate saved sound path — if it doesn't exist in current sounds, reset it
    final savedSound = prefs.getString(AppConstants.keyDefaultSound);
    final validSound = AppConstants.alarmSounds.values.contains(savedSound)
        ? savedSound!
        : AppConstants.alarmSounds.values.first; // always falls back to first real file

    return AppSettings(
      themeMode: ThemeMode.values[themeModeIndex],
      defaultSnoozeDuration: prefs.getInt(AppConstants.keySnoozeDuration) ?? 5,
      defaultSoundPath: validSound,
      use24HourFormat: prefs.getBool(AppConstants.keyUse24h) ?? false,
      userName: prefs.getString(AppConstants.keyUserName) ?? '',
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyThemeMode, mode.index);
    state = AsyncData(state.value!.copyWith(themeMode: mode));
  }

  Future<void> setSnoozeDuration(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keySnoozeDuration, minutes);
    state = AsyncData(state.value!.copyWith(defaultSnoozeDuration: minutes));
  }

  Future<void> setDefaultSound(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyDefaultSound, path);
    state = AsyncData(state.value!.copyWith(defaultSoundPath: path));
  }

  Future<void> setTimeFormat(bool use24h) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyUse24h, use24h);
    state = AsyncData(state.value!.copyWith(use24HourFormat: use24h));
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserName, name);
    state = AsyncData(state.value!.copyWith(userName: name));
  }
}