import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../providers/todo_provider.dart';
import '../widgets/persistent_mascot.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  final _titleCtrl = TextEditingController();
  DateTime? _pickedTime;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) {
      final today = DateTime.now();
      setState(() {
        _pickedTime = DateTime(
            today.year, today.month, today.day, picked.hour, picked.minute);
      });
    }
  }

  void _add() {
    final text = _titleCtrl.text.trim();
    if (text.isEmpty) return;
    ref
        .read(globalTodoProvider.notifier)
        .addTask(text, scheduledTime: _pickedTime);
    _titleCtrl.clear();
    setState(() => _pickedTime = null);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(globalTodoProvider);
    final cs = Theme.of(context).colorScheme;
    final timeFmt = DateFormat('h:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text('To-Do')),
      body: Stack(
        children: [
          Column(
            children: [
              // ── Add task ───────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleCtrl,
                      onSubmitted: (_) => _add(),
                      decoration: InputDecoration(
                        hintText: 'Add a task…',
                        filled: true,
                        fillColor: cs.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Time chip
                        GestureDetector(
                          onTap: _pickTime,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _pickedTime != null
                                  ? cs.primary
                                  : cs.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: cs.outline.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.schedule_rounded,
                                    size: 16,
                                    color: _pickedTime != null
                                        ? Colors.white
                                        : cs.primary),
                                const SizedBox(width: 6),
                                Text(
                                  _pickedTime != null
                                      ? timeFmt.format(_pickedTime!)
                                      : 'Set time',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _pickedTime != null
                                        ? Colors.white
                                        : cs.primary,
                                  ),
                                ),
                                if (_pickedTime != null) ...[
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () =>
                                        setState(() => _pickedTime = null),
                                    child: const Icon(Icons.close,
                                        size: 14, color: Colors.white),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: _add,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Progress ───────────────────────────────────────────────
              tasksAsync.maybeWhen(
                data: (tasks) {
                  final done = tasks.where((t) => t.isDone).length;
                  final total = tasks.length;
                  if (total == 0) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    child: Row(
                      children: [
                        Text('$done / $total done',
                            style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: done / total,
                              minHeight: 6,
                              backgroundColor:
                              cs.primary.withValues(alpha: 0.12),
                              valueColor:
                              AlwaysStoppedAnimation<Color>(cs.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                orElse: () => const SizedBox(),
              ),

              const Divider(height: 1),

              // ── Task list ─────────────────────────────────────────────
              Expanded(
                child: tasksAsync.when(
                  loading: () =>
                  const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return Center(
                        child: Text('All clear! Add a task.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                color: cs.onSurface
                                    .withValues(alpha: 0.35))),
                      );
                    }

                    // Sort by scheduled time, then pending first
                    final sorted = [...tasks]..sort((a, b) {
                      if (a.isDone != b.isDone) {
                        return a.isDone ? 1 : -1;
                      }
                      if (a.scheduledTime != null &&
                          b.scheduledTime != null) {
                        return a.scheduledTime!
                            .compareTo(b.scheduledTime!);
                      }
                      if (a.scheduledTime != null) return -1;
                      if (b.scheduledTime != null) return 1;
                      return 0;
                    });

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                      itemCount: sorted.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final task = sorted[i];
                        return _TodoTile(
                          key: ValueKey(task.id),
                          task: task,
                          onToggle: () => ref
                              .read(globalTodoProvider.notifier)
                              .toggleTask(task.id),
                          onDelete: () => ref
                              .read(globalTodoProvider.notifier)
                              .deleteTask(task.id),
                        ).animate().fadeIn(duration: 250.ms);
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // ── Mascot ─────────────────────────────────────────────────────
          const Positioned(
            left: 0,
            bottom: 16,
            child: PersistentMascot(context: MascotContext.todo),
          ),
        ],
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  final TodoTask task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TodoTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: cs.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.delete_outline_rounded, color: cs.error),
      ),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: task.isDone
                ? cs.primary.withValues(alpha: 0.07)
                : cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: task.isDone
                  ? cs.primary.withValues(alpha: 0.25)
                  : cs.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              // Time indicator bar
              if (task.scheduledTime != null)
                Container(
                  width: 3,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: task.isDone
                        ? cs.primary.withValues(alpha: 0.3)
                        : cs.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

              Icon(
                task.isDone
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: task.isDone
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.35),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isDone
                            ? cs.onSurface.withValues(alpha: 0.4)
                            : cs.onSurface,
                      ),
                    ),
                    if (task.timeLabel != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Row(
                          children: [
                            Icon(Icons.schedule_rounded,
                                size: 12, color: cs.primary),
                            const SizedBox(width: 4),
                            Text(
                              task.timeLabel!,
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}