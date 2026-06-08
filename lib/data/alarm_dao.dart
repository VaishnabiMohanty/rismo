import 'package:floor/floor.dart';

import '../models/alarm_model.dart';

@dao
abstract class AlarmDao {
  // ── Read ──────────────────────────────────────────────────────────────────

  @Query('SELECT * FROM AlarmModel ORDER BY hour ASC, minute ASC')
  Future<List<AlarmModel>> getAllAlarms();

  @Query('SELECT * FROM AlarmModel WHERE id = :id')
  Future<AlarmModel?> getAlarmById(String id);

  @Query('SELECT * FROM AlarmModel WHERE isEnabled = 1')
  Future<List<AlarmModel>> getEnabledAlarms();

  // ── Write ─────────────────────────────────────────────────────────────────

  @insert
  Future<void> insertAlarm(AlarmModel alarm);

  @update
  Future<void> updateAlarm(AlarmModel alarm);

  // ── Delete ────────────────────────────────────────────────────────────────

  @Query('DELETE FROM AlarmModel WHERE id = :id')
  Future<void> deleteAlarmById(String id);

  @Query('DELETE FROM AlarmModel')
  Future<void> deleteAllAlarms();
}