import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class TodoTask {
  final String id;
  final String title;
  final bool isDone;
  final DateTime createdAt;

  const TodoTask({
    required this.id,
    required this.title,
    required this.isDone,
    required this.createdAt,
  });

  TodoTask copyWith({String? title, bool? isDone}) => TodoTask(
    id: id,
    title: title ?? this.title,
    isDone: isDone ?? this.isDone,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isDone': isDone,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory TodoTask.fromJson(Map<String, dynamic> j) => TodoTask(
    id: j['id'] as String,
    title: j['title'] as String,
    isDone: j['isDone'] as bool,
    createdAt:
    DateTime.fromMillisecondsSinceEpoch(j['createdAt'] as int),
  );
}

// ── Provider — keyed by alarmId ───────────────────────────────────────────────

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
        .map((s) => TodoTask.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> addTask(String title) async {
    final task = TodoTask(
      id: _uuid.v4(),
      title: title,
      isDone: false,
      createdAt: DateTime.now(),
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
      _key,
      tasks.map((t) => jsonEncode(t.toJson())).toList(),
    );
  }
}

// ── Global todo (not alarm-specific) ─────────────────────────────────────────

final globalTodoProvider =
AsyncNotifierProvider<GlobalTodoNotifier, List<TodoTask>>(
  GlobalTodoNotifier.new,
);

class GlobalTodoNotifier extends AsyncNotifier<List<TodoTask>> {
  static const _key = 'todos_global';
  static const _uuid = Uuid();

  @override
  Future<List<TodoTask>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) => TodoTask.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> addTask(String title) async {
    final task = TodoTask(
      id: _uuid.v4(),
      title: title,
      isDone: false,
      createdAt: DateTime.now(),
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
      _key,
      tasks.map((t) => jsonEncode(t.toJson())).toList(),
    );
  }
}