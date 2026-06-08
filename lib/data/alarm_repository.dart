import '../models/alarm_model.dart';
import 'alarm_database.dart';
import 'alarm_dao.dart';

class AlarmRepository {
  AlarmDao? _dao;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<AlarmDao> get _alarmDao async {
    _dao ??= (await AlarmDatabase.getInstance()).alarmDao;
    return _dao!;
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<List<AlarmModel>> getAllAlarms() async {
    final dao = await _alarmDao;
    return dao.getAllAlarms();
  }

  Future<AlarmModel?> getAlarmById(String id) async {
    final dao = await _alarmDao;
    return dao.getAlarmById(id);
  }

  Future<List<AlarmModel>> getEnabledAlarms() async {
    final dao = await _alarmDao;
    return dao.getEnabledAlarms();
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> insertAlarm(AlarmModel alarm) async {
    final dao = await _alarmDao;
    await dao.insertAlarm(alarm);
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    final dao = await _alarmDao;
    await dao.updateAlarm(alarm);
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteAlarm(String id) async {
    final dao = await _alarmDao;
    await dao.deleteAlarmById(id);
  }

  Future<void> deleteAllAlarms() async {
    final dao = await _alarmDao;
    await dao.deleteAllAlarms();
  }
}