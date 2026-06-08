// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AlarmDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AlarmDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AlarmDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AlarmDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAlarmDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AlarmDatabaseBuilderContract databaseBuilder(String name) =>
      _$AlarmDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AlarmDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AlarmDatabaseBuilder(null);
}

class _$AlarmDatabaseBuilder implements $AlarmDatabaseBuilderContract {
  _$AlarmDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AlarmDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AlarmDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AlarmDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AlarmDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AlarmDatabase extends AlarmDatabase {
  _$AlarmDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  AlarmDao? _alarmDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `AlarmModel` (`id` TEXT NOT NULL, `hour` INTEGER NOT NULL, `minute` INTEGER NOT NULL, `label` TEXT NOT NULL, `repeatDays` TEXT NOT NULL, `isEnabled` INTEGER NOT NULL, `soundPath` TEXT NOT NULL, `snoozeDuration` INTEGER NOT NULL, `streakCount` INTEGER NOT NULL, `avatarPath` TEXT, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  AlarmDao get alarmDao {
    return _alarmDaoInstance ??= _$AlarmDao(database, changeListener);
  }
}

class _$AlarmDao extends AlarmDao {
  _$AlarmDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _alarmModelInsertionAdapter = InsertionAdapter(
            database,
            'AlarmModel',
            (AlarmModel item) => <String, Object?>{
                  'id': item.id,
                  'hour': item.hour,
                  'minute': item.minute,
                  'label': item.label,
                  'repeatDays': item.repeatDays,
                  'isEnabled': item.isEnabled ? 1 : 0,
                  'soundPath': item.soundPath,
                  'snoozeDuration': item.snoozeDuration,
                  'streakCount': item.streakCount,
                  'avatarPath': item.avatarPath
                }),
        _alarmModelUpdateAdapter = UpdateAdapter(
            database,
            'AlarmModel',
            ['id'],
            (AlarmModel item) => <String, Object?>{
                  'id': item.id,
                  'hour': item.hour,
                  'minute': item.minute,
                  'label': item.label,
                  'repeatDays': item.repeatDays,
                  'isEnabled': item.isEnabled ? 1 : 0,
                  'soundPath': item.soundPath,
                  'snoozeDuration': item.snoozeDuration,
                  'streakCount': item.streakCount,
                  'avatarPath': item.avatarPath
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AlarmModel> _alarmModelInsertionAdapter;

  final UpdateAdapter<AlarmModel> _alarmModelUpdateAdapter;

  @override
  Future<List<AlarmModel>> getAllAlarms() async {
    return _queryAdapter.queryList(
        'SELECT * FROM AlarmModel ORDER BY hour ASC, minute ASC',
        mapper: (Map<String, Object?> row) => AlarmModel(
            id: row['id'] as String,
            hour: row['hour'] as int,
            minute: row['minute'] as int,
            label: row['label'] as String,
            repeatDays: row['repeatDays'] as String,
            isEnabled: (row['isEnabled'] as int) != 0,
            soundPath: row['soundPath'] as String,
            snoozeDuration: row['snoozeDuration'] as int,
            streakCount: row['streakCount'] as int,
            avatarPath: row['avatarPath'] as String?));
  }

  @override
  Future<AlarmModel?> getAlarmById(String id) async {
    return _queryAdapter.query('SELECT * FROM AlarmModel WHERE id = ?1',
        mapper: (Map<String, Object?> row) => AlarmModel(
            id: row['id'] as String,
            hour: row['hour'] as int,
            minute: row['minute'] as int,
            label: row['label'] as String,
            repeatDays: row['repeatDays'] as String,
            isEnabled: (row['isEnabled'] as int) != 0,
            soundPath: row['soundPath'] as String,
            snoozeDuration: row['snoozeDuration'] as int,
            streakCount: row['streakCount'] as int,
            avatarPath: row['avatarPath'] as String?),
        arguments: [id]);
  }

  @override
  Future<List<AlarmModel>> getEnabledAlarms() async {
    return _queryAdapter.queryList(
        'SELECT * FROM AlarmModel WHERE isEnabled = 1',
        mapper: (Map<String, Object?> row) => AlarmModel(
            id: row['id'] as String,
            hour: row['hour'] as int,
            minute: row['minute'] as int,
            label: row['label'] as String,
            repeatDays: row['repeatDays'] as String,
            isEnabled: (row['isEnabled'] as int) != 0,
            soundPath: row['soundPath'] as String,
            snoozeDuration: row['snoozeDuration'] as int,
            streakCount: row['streakCount'] as int,
            avatarPath: row['avatarPath'] as String?));
  }

  @override
  Future<void> deleteAlarmById(String id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM AlarmModel WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteAllAlarms() async {
    await _queryAdapter.queryNoReturn('DELETE FROM AlarmModel');
  }

  @override
  Future<void> insertAlarm(AlarmModel alarm) async {
    await _alarmModelInsertionAdapter.insert(alarm, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAlarm(AlarmModel alarm) async {
    await _alarmModelUpdateAdapter.update(alarm, OnConflictStrategy.abort);
  }
}
