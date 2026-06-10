import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/todo_provider.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(globalTodoProvider.notifier).addTask(text);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(globalTodoProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Add task bar ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _add(),
                    decoration: InputDecoration(
                      hintText: 'Add a task for tomorrow…',
                      prefixIcon: Icon(Icons.add_task_rounded,
                          color: cs.primary),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _add,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),

          // ── Stats row ────────────────────────────────────────────────────
          tasksAsync.maybeWhen(
            data: (tasks) {
              final done = tasks.where((t) => t.isDone).length;
              final total = tasks.length;
              if (total == 0) return const SizedBox();
              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      '$done / $total done',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : done / total,
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

          // ── Task list ────────────────────────────────────────────────────
          Expanded(
            child: tasksAsync.when(
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 64,
                            color: cs.onSurface.withValues(alpha: 0.15)),
                        const SizedBox(height: 16),
                        Text(
                          'All clear! Add tasks for tomorrow.',
                          style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Show pending first, then done
                final pending = tasks.where((t) => !t.isDone).toList();
                final done = tasks.where((t) => t.isDone).toList();
                final sorted = [...pending, ...done];

                return ListView.separated(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
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
                    ).animate().fadeIn(duration: 300.ms);
                  },
                );
              },
            ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  task.isDone
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  key: ValueKey(task.isDone),
                  color: task.isDone
                      ? cs.primary
                      : cs.onSurface.withValues(alpha: 0.35),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    decoration:
                    task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isDone
                        ? cs.onSurface.withValues(alpha: 0.4)
                        : cs.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}