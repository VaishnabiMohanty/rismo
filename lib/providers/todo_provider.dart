import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class TodoTask {
  final String id;
  final String title;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? scheduledTime; // for timetable/timestamp

  const TodoTask({
    required this.id,
    required this.title,
    required this.isDone,
    required this.createdAt,
    this.scheduledTime,
  });

  // Human-readable time label e.g. "9:00 AM"
  String? get timeLabel {
    if (scheduledTime == null) return null;
    final h = scheduledTime!.hour;
    final m = scheduledTime!.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m $period';
  }

  TodoTask copyWith({String? title, bool? isDone, DateTime? scheduledTime}) =>
      TodoTask(
        id: id,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
        createdAt: createdAt,
        scheduledTime: scheduledTime ?? this.scheduledTime,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isDone': isDone,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'scheduledTime': scheduledTime?.millisecondsSinceEpoch,
  };

  factory TodoTask.fromJson(Map<String, dynamic> j) => TodoTask(
    id: j['id'] as String,
    title: j['title'] as String,
    isDone: j['isDone'] as bool,
    createdAt:
    DateTime.fromMillisecondsSinceEpoch(j['createdAt'] as int),
    scheduledTime: j['scheduledTime'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
        j['scheduledTime'] as int)
        : null,
  );
}

// ── Alarm-keyed provider ──────────────────────────────────────────────────────

final todoProvider =
AsyncNotifierProviderFamily<TodoNotifier, List<TodoTask>, String>(
      () => TodoNotifier(),
);

class TodoNotifier extends FamilyAsyncNotifier<List<TodoTask>, String> {
  static const _uuid = Uuid();
  String get _key => 'todos_${arg}';

  @override
  Future<List<TodoTask>> build(String arg) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) =>
        TodoTask.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> addTask(String title, {DateTime? scheduledTime}) async {
    final task = TodoTask(
      id: const Uuid().v4(),
      title: title,
      isDone: false,
      createdAt: DateTime.now(),
      scheduledTime: scheduledTime,
    );
    final current = <TodoTask>[...(state.value ?? []), task];
    state = AsyncData(current);
    await _persist(current);
  }

  Future<void> toggleTask(String taskId) async {
    final updated = (state.value ?? [])
        .map((t) => t.id == taskId ? t.copyWith(isDone: !t.isDone) : t)
        .toList();
    state = AsyncData(updated);
    await _persist(updated);
  }

  Future<void> deleteTask(String taskId) async {
    final updated =
    (state.value ?? []).where((t) => t.id != taskId).toList();
    state = AsyncData(updated);
    await _persist(updated);
  }

  Future<void> _persist(List<TodoTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, tasks.map((t) => jsonEncode(t.toJson())).toList());
  }
}

// ── Global todo ───────────────────────────────────────────────────────────────

final globalTodoProvider =
AsyncNotifierProvider<GlobalTodoNotifier, List<TodoTask>>(
  GlobalTodoNotifier.new,
);

class GlobalTodoNotifier extends AsyncNotifier<List<TodoTask>> {
  static const _key = 'todos_global';

  @override
  Future<List<TodoTask>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) =>
        TodoTask.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> addTask(String title, {DateTime? scheduledTime}) async {
    final task = TodoTask(
      id: const Uuid().v4(),
      title: title,
      isDone: false,
      createdAt: DateTime.now(),
      scheduledTime: scheduledTime,
    );
    final current = <TodoTask>[...(state.value ?? []), task];
    state = AsyncData(current);
    await _persist(current);
  }

  Future<void> toggleTask(String taskId) async {
    final updated = (state.value ?? [])
        .map((t) => t.id == taskId ? t.copyWith(isDone: !t.isDone) : t)
        .toList();
    state = AsyncData(updated);
    await _persist(updated);
  }

  Future<void> deleteTask(String taskId) async {
    final updated =
    (state.value ?? []).where((t) => t.id != taskId).toList();
    state = AsyncData(updated);
    await _persist(updated);
  }

  Future<void> _persist(List<TodoTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, tasks.map((t) => jsonEncode(t.toJson())).toList());
  }
}

// ── Calendar events (tasks stored per date) ───────────────────────────────────

final calendarTasksProvider =
AsyncNotifierProvider<CalendarTasksNotifier, Map<String, List<TodoTask>>>(
  CalendarTasksNotifier.new,
);

class CalendarTasksNotifier
    extends AsyncNotifier<Map<String, List<TodoTask>>> {
  static const _key = 'calendar_tasks';

  @override
  Future<Map<String, List<TodoTask>>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((date, tasksJson) {
      final list = (tasksJson as List)
          .map((t) => TodoTask.fromJson(t as Map<String, dynamic>))
          .toList();
      return MapEntry(date, list);
    });
  }

  List<TodoTask> tasksForDate(DateTime date) {
    final key = _dateKey(date);
    return state.value?[key] ?? [];
  }

  Future<void> addTask(DateTime date, String title,
      {DateTime? scheduledTime}) async {
    final task = TodoTask(
      id: const Uuid().v4(),
      title: title,
      isDone: false,
      createdAt: DateTime.now(),
      scheduledTime: scheduledTime,
    );
    final current =
    Map<String, List<TodoTask>>.from(state.value ?? {});
    final key = _dateKey(date);
    current[key] = [...(current[key] ?? []), task];
    state = AsyncData(current);
    await _persist(current);
  }

  Future<void> toggleTask(DateTime date, String taskId) async {
    final current =
    Map<String, List<TodoTask>>.from(state.value ?? {});
    final key = _dateKey(date);
    current[key] = (current[key] ?? [])
        .map((t) => t.id == taskId ? t.copyWith(isDone: !t.isDone) : t)
        .toList();
    state = AsyncData(current);
    await _persist(current);
  }

  Future<void> deleteTask(DateTime date, String taskId) async {
    final current =
    Map<String, List<TodoTask>>.from(state.value ?? {});
    final key = _dateKey(date);
    current[key] =
        (current[key] ?? []).where((t) => t.id != taskId).toList();
    state = AsyncData(current);
    await _persist(current);
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _persist(Map<String, List<TodoTask>> data) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(data
        .map((k, v) => MapEntry(k, v.map((t) => t.toJson()).toList())));
    await prefs.setString(_key, encoded);
  }
}