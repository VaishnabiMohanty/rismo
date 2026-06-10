import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../providers/todo_provider.dart';
import '../widgets/persistent_mascot.dart';

// ── Holiday data ──────────────────────────────────────────────────────────────

class _Holiday {
  final String name;
  final bool isInternational;
  const _Holiday(this.name, {this.isInternational = false});
}

Map<String, List<_Holiday>> _buildHolidays(int year) {
  return {
    // ── International ──────────────────────────────────────────────────────
    '$year-01-01': [_Holiday("New Year's Day", isInternational: true)],
    '$year-02-14': [_Holiday("Valentine's Day", isInternational: true)],
    '$year-03-08': [_Holiday("International Women's Day", isInternational: true)],
    '$year-03-14': [_Holiday('Pi Day', isInternational: true)],
    '$year-04-01': [_Holiday("April Fool's Day", isInternational: true)],
    '$year-04-22': [_Holiday('Earth Day', isInternational: true)],
    '$year-05-01': [_Holiday('International Labour Day', isInternational: true)],
    '$year-06-05': [_Holiday('World Environment Day', isInternational: true)],
    '$year-06-21': [_Holiday("International Yoga Day", isInternational: true)],
    '$year-10-02': [_Holiday('Gandhi Jayanti 🇮🇳'), _Holiday('International Day of Non-Violence', isInternational: true)],
    '$year-10-16': [_Holiday('World Food Day', isInternational: true)],
    '$year-10-31': [_Holiday('Halloween', isInternational: true)],
    '$year-11-14': [_Holiday("Children's Day 🇮🇳")],
    '$year-12-10': [_Holiday('Human Rights Day', isInternational: true)],
    '$year-12-25': [_Holiday('Christmas Day', isInternational: true)],
    '$year-12-31': [_Holiday("New Year's Eve", isInternational: true)],

    // ── India national holidays ────────────────────────────────────────────
    '$year-01-26': [_Holiday('Republic Day 🇮🇳')],
    '$year-08-15': [_Holiday('Independence Day 🇮🇳')],
    '$year-11-01': [_Holiday('Kannada Rajyotsava 🇮🇳')],

    // ── Major Indian festivals (fixed or approximate) ─────────────────────
    '$year-01-14': [_Holiday('Makar Sankranti / Pongal 🇮🇳')],
    '$year-01-15': [_Holiday('Pongal Day 2 🇮🇳')],
    '$year-03-25': [_Holiday('Holi 🇮🇳')],
    '$year-03-30': [_Holiday('Ram Navami 🇮🇳')],
    '$year-04-06': [_Holiday('Mahavir Jayanti 🇮🇳')],
    '$year-04-14': [_Holiday('Dr. Ambedkar Jayanti / Tamil New Year 🇮🇳')],
    '$year-04-18': [_Holiday('Good Friday', isInternational: true)],
    '$year-05-12': [_Holiday('Buddha Purnima 🇮🇳')],
    '$year-07-10': [_Holiday('Eid ul-Adha (approx) 🇮🇳')],
    '$year-08-09': [_Holiday('Muharram (approx) 🇮🇳')],
    '$year-08-16': [_Holiday('Janmashtami 🇮🇳')],
    '$year-10-02': [_Holiday('Gandhi Jayanti 🇮🇳')],
    '$year-10-13': [_Holiday('Navratri begins 🇮🇳')],
    '$year-10-20': [_Holiday('Dussehra 🇮🇳')],
    '$year-10-20': [_Holiday('Durga Puja / Vijaya Dashami 🇮🇳')],
    '$year-11-01': [_Holiday('Diwali (Lakshmi Puja) 🇮🇳')],
    '$year-11-05': [_Holiday('Bhai Dooj 🇮🇳')],
    '$year-11-15': [_Holiday('Guru Nanak Jayanti 🇮🇳')],
    '$year-12-25': [_Holiday('Christmas 🇮🇳')],
  };
}

// ── Calendar screen ───────────────────────────────────────────────────────────

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime.now();
  late Map<String, List<_Holiday>> _holidays;

  @override
  void initState() {
    super.initState();
    _holidays = _buildHolidays(DateTime.now().year);
    // Build for next year too
    _holidays.addAll(_buildHolidays(DateTime.now().year + 1));
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<_Holiday> _holidaysFor(DateTime d) =>
      _holidays[_dateKey(d)] ?? [];

  List<TodoTask> _tasksFor(DateTime d) {
    return ref
        .read(calendarTasksProvider)
        .value
    ?[_dateKey(d)] ?? [];
  }

  void _prevMonth() => setState(() {
    _focusedMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month - 1);
  });

  void _nextMonth() => setState(() {
    _focusedMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1);
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    ref.watch(calendarTasksProvider); // reactive
    final monthFmt = DateFormat('MMMM yyyy');
    final now = DateTime.now();

    // Build calendar grid
    final firstDay =
    DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startWeekday = firstDay.weekday % 7; // 0=Sun
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

    final selectedTasks = _tasksFor(_selectedDay);
    final selectedHolidays = _holidaysFor(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            onPressed: () => setState(() {
              _focusedMonth =
                  DateTime(now.year, now.month);
              _selectedDay = now;
            }),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ── Month header ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: _prevMonth,
                    ),
                    Text(
                      monthFmt.format(_focusedMonth),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),

              // ── Day-of-week header ──────────────────────────────────────
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
                      .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface
                              .withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ),

              const SizedBox(height: 4),

              // ── Calendar grid ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: startWeekday + daysInMonth,
                  itemBuilder: (_, i) {
                    if (i < startWeekday) return const SizedBox();
                    final day = i - startWeekday + 1;
                    final date = DateTime(
                        _focusedMonth.year, _focusedMonth.month, day);
                    final isToday = date.year == now.year &&
                        date.month == now.month &&
                        date.day == now.day;
                    final isSelected =
                        date.year == _selectedDay.year &&
                            date.month == _selectedDay.month &&
                            date.day == _selectedDay.day;
                    final holidays = _holidaysFor(date);
                    final hasTasks = _tasksFor(date).isNotEmpty;

                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedDay = date),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cs.primary
                              : isToday
                              ? cs.primaryContainer
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isToday || isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                    ? cs.primary
                                    : cs.onSurface,
                              ),
                            ),
                            // Dot indicators
                            if (holidays.isNotEmpty || hasTasks)
                              Positioned(
                                bottom: 3,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (holidays.isNotEmpty)
                                      Container(
                                        width: 4,
                                        height: 4,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 1),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFF6B35),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    if (hasTasks)
                                      Container(
                                        width: 4,
                                        height: 4,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 1),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white70
                                              : cs.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Divider(height: 1),

              // ── Selected day details ────────────────────────────────────
              Expanded(
                child: _DayDetail(
                  selectedDay: _selectedDay,
                  holidays: selectedHolidays,
                  tasks: selectedTasks,
                ),
              ),
            ],
          ),

          // ── Mascot ───────────────────────────────────────────────────────
          const Positioned(
            left: 0,
            bottom: 16,
            child: PersistentMascot(context: MascotContext.calendar),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTaskSheet(
        date: _selectedDay,
        onAdd: (title, time) {
          ref
              .read(calendarTasksProvider.notifier)
              .addTask(_selectedDay, title, scheduledTime: time);
          setState(() {});
        },
      ),
    );
  }
}

// ── Day detail panel ──────────────────────────────────────────────────────────

class _DayDetail extends ConsumerWidget {
  final DateTime selectedDay;
  final List<_Holiday> holidays;
  final List<TodoTask> tasks;

  const _DayDetail({
    required this.selectedDay,
    required this.holidays,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('EEEE, MMM d');
    final calNotifier = ref.read(calendarTasksProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // Date heading
        Text(
          dateFmt.format(selectedDay),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Holidays
        if (holidays.isNotEmpty) ...[
          ...holidays.map((h) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: h.isInternational
                  ? const Color(0xFF1565C0).withValues(alpha: 0.12)
                  : const Color(0xFFFF6B35).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: h.isInternational
                    ? cs.primary.withValues(alpha: 0.3)
                    : const Color(0xFFFF6B35).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  h.isInternational
                      ? Icons.public_rounded
                      : Icons.celebration_rounded,
                  size: 16,
                  color: h.isInternational
                      ? cs.primary
                      : const Color(0xFFFF6B35),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    h.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: h.isInternational
                          ? cs.primary
                          : const Color(0xFFFF6B35),
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),
        ],

        // Tasks
        if (tasks.isEmpty && holidays.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Center(
              child: Text('Nothing scheduled — tap + to add!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.35),
                  )),
            ),
          ),

        ...tasks.map((task) => Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) =>
              calNotifier.deleteTask(selectedDay, task.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: cs.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.delete_outline_rounded, color: cs.error),
          ),
          child: GestureDetector(
            onTap: () =>
                calNotifier.toggleTask(selectedDay, task.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: task.isDone
                    ? cs.primary.withValues(alpha: 0.07)
                    : cs.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: cs.outline.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  if (task.scheduledTime != null)
                    Container(
                      width: 3,
                      height: 36,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: cs.primary,
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
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 14,
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
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded,
                                  size: 11, color: cs.primary),
                              const SizedBox(width: 3),
                              Text(
                                task.timeLabel!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: cs.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 200.ms),
        )),
      ],
    );
  }
}

// ── Add task bottom sheet ─────────────────────────────────────────────────────

class _AddTaskSheet extends StatefulWidget {
  final DateTime date;
  final void Function(String title, DateTime? time) onAdd;
  const _AddTaskSheet({required this.date, required this.onAdd});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _ctrl = TextEditingController();
  DateTime? _time;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
        context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        _time = DateTime(
          widget.date.year,
          widget.date.month,
          widget.date.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('EEE, MMM d');
    final timeFmt = DateFormat('h:mm a');

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add task for ${dateFmt.format(widget.date)}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Task title…',
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: _pickTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _time != null
                          ? cs.primary
                          : cs.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 16,
                            color: _time != null
                                ? Colors.white
                                : cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          _time != null
                              ? timeFmt.format(_time!)
                              : 'Add time',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _time != null
                                ? Colors.white
                                : cs.primary,
                          ),
                        ),
                        if (_time != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => _time = null),
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
                  onPressed: _submit,
                  child: const Text('Add Task'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text, _time);
    Navigator.pop(context);
  }
}