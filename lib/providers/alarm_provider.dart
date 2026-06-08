import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/alarm_model.dart';
import '../data/alarm_repository.dart';
import '../services/alarm_service.dart';

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  return AlarmRepository();
});

final alarmProvider =
AsyncNotifierProvider<AlarmNotifier, List<AlarmModel>>(AlarmNotifier.new);

class AlarmNotifier extends AsyncNotifier<List<AlarmModel>> {
  late AlarmRepository _repository;

  @override
  Future<List<AlarmModel>> build() async {
    _repository = ref.read(alarmRepositoryProvider);
    return await _repository.getAllAlarms();
  }

  // ── Add ───────────────────────────────────────────────────────────────────

  Future<bool> addAlarm({
    required int hour,
    required int minute,
    required String label,
    required String repeatDays,
    required String soundPath,
    required int snoozeDuration,
  }) async {
    try {
      final alarm = AlarmModel(
        id: const Uuid().v4(),
        hour: hour,
        minute: minute,
        label: label,
        repeatDays: repeatDays,
        isEnabled: true,
        soundPath: soundPath,
        snoozeDuration: snoozeDuration,
        streakCount: 0,
      );

      // Save to DB first
      await _repository.insertAlarm(alarm);

      // Then schedule — if this fails alarm is still saved
      try {
        await AlarmService.scheduleAlarm(alarm);
      } catch (e) {
        debugPrint('Alarm scheduling failed: $e');
      }

      // Reload from DB to confirm save
      final updated = await _repository.getAllAlarms();
      state = AsyncData(updated);
      return true;
    } catch (e) {
      debugPrint('addAlarm error: $e');
      return false;
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<bool> updateAlarm(AlarmModel updated) async {
    try {
      await _repository.updateAlarm(updated);
      await AlarmService.cancelAlarm(updated);
      if (updated.isEnabled) {
        await AlarmService.scheduleAlarm(updated);
      }
      final all = await _repository.getAllAlarms();
      state = AsyncData(all);
      return true;
    } catch (e) {
      debugPrint('updateAlarm error: $e');
      return false;
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteAlarm(String id) async {
    try {
      final alarm = state.value?.firstWhere((a) => a.id == id);
      if (alarm != null) await AlarmService.cancelAlarm(alarm);
      await _repository.deleteAlarm(id);
      final all = await _repository.getAllAlarms();
      state = AsyncData(all);
    } catch (e) {
      debugPrint('deleteAlarm error: $e');
    }
  }

  // ── Toggle ────────────────────────────────────────────────────────────────

  Future<void> toggleAlarm(String id, bool isEnabled) async {
    try {
      final alarm = state.value?.firstWhere((a) => a.id == id);
      if (alarm == null) return;
      final updated = alarm.copyWith(isEnabled: isEnabled);
      await _repository.updateAlarm(updated);
      if (isEnabled) {
        await AlarmService.scheduleAlarm(updated);
      } else {
        await AlarmService.cancelAlarm(updated);
      }
      final all = await _repository.getAllAlarms();
      state = AsyncData(all);
    } catch (e) {
      debugPrint('toggleAlarm error: $e');
    }
  }

  // ── Streak ────────────────────────────────────────────────────────────────

  Future<void> incrementStreak(String id) async {
    final alarm = state.value?.firstWhere((a) => a.id == id);
    if (alarm == null) return;
    final updated = alarm.copyWith(streakCount: alarm.streakCount + 1);
    await _repository.updateAlarm(updated);
    final all = await _repository.getAllAlarms();
    state = AsyncData(all);
  }

  Future<void> resetStreak(String id) async {
    final alarm = state.value?.firstWhere((a) => a.id == id);
    if (alarm == null) return;
    final updated = alarm.copyWith(streakCount: 0);
    await _repository.updateAlarm(updated);
    final all = await _repository.getAllAlarms();
    state = AsyncData(all);
  }
}