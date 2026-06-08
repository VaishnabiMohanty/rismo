import 'package:flutter/material.dart';

class DaySelector extends StatefulWidget {
  final List<int> selectedDays; // 1=Mon, 2=Tue ... 7=Sun
  final ValueChanged<List<int>> onChanged;

  const DaySelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  late List<int> _selected;

  static const _days = [
    (1, 'M'),
    (2, 'T'),
    (3, 'W'),
    (4, 'T'),
    (5, 'F'),
    (6, 'S'),
    (7, 'S'),
  ];

  static const _fullNames = [
    'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedDays);
  }

  void _toggle(int day) {
    setState(() {
      if (_selected.contains(day)) {
        _selected.remove(day);
      } else {
        _selected.add(day);
        _selected.sort();
      }
    });
    widget.onChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Day circles ──────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _days.map((entry) {
            final (dayNum, label) = entry;
            final isSelected = _selected.contains(dayNum);

            return GestureDetector(
              onTap: () => _toggle(dayNum),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceVariant,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),

        // ── Summary text ─────────────────────────────────────────────────────
        Text(
          _selected.isEmpty
              ? 'One-time alarm — will not repeat'
              : _selected.length == 7
              ? 'Every day'
              : _selected.length == 5 &&
              !_selected.contains(6) &&
              !_selected.contains(7)
              ? 'Weekdays only'
              : _selected.length == 2 &&
              _selected.contains(6) &&
              _selected.contains(7)
              ? 'Weekends only'
              : _selected
              .map((d) => _fullNames[d - 1])
              .join(', '),
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onBackground.withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}