import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TimePickerWidget extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const TimePickerWidget({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
  });

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  late int _selectedHour;
  late int _selectedMinute;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
    _hourController =
        FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController =
        FixedExtentScrollController(initialItem: _selectedMinute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onTimeChanged(
      TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Selection highlight bar ────────────────────────────────────────
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // ── Scrollers ──────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hours
              SizedBox(
                width: 80,
                child: CupertinoPicker(
                  scrollController: _hourController,
                  itemExtent: 48,
                  looping: true,
                  selectionOverlay: const SizedBox(),
                  onSelectedItemChanged: (index) {
                    setState(() => _selectedHour = index % 24);
                    _notify();
                  },
                  children: List.generate(
                    24,
                        (i) => Center(
                      child: Text(
                        i.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Colon
              Text(
                ':',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),

              // Minutes
              SizedBox(
                width: 80,
                child: CupertinoPicker(
                  scrollController: _minuteController,
                  itemExtent: 48,
                  looping: true,
                  selectionOverlay: const SizedBox(),
                  onSelectedItemChanged: (index) {
                    setState(() => _selectedMinute = index % 60);
                    _notify();
                  },
                  children: List.generate(
                    60,
                        (i) => Center(
                      child: Text(
                        i.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}