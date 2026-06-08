import 'dart:async';
import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/alarm_model.dart';
import 'alarm_dao.dart';

part 'alarm_database.g.dart';

@Database(version: 1, entities: [AlarmModel])
abstract class AlarmDatabase extends FloorDatabase {
  AlarmDao get alarmDao;

  static AlarmDatabase? _instance;

  static Future<AlarmDatabase> getInstance() async {
    if (_instance != null) return _instance!;

    try {
      _instance = await $FloorAlarmDatabase
          .databaseBuilder('rismo_alarms.db')
          .build();
    } catch (e) {
      // If DB is corrupted, delete and recreate fresh
      debugPrint('DB build failed, recreating: $e');
      final dbPath = await sqflite.getDatabasesPath();
      await sqflite.deleteDatabase('$dbPath/rismo_alarms.db');
      _instance = await $FloorAlarmDatabase
          .databaseBuilder('rismo_alarms.db')
          .build();
    }

    return _instance!;
  }
}