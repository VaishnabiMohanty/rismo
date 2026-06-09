import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/alarm_model.dart';
import '../providers/alarm_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/day_selector.dart';
import '../utils/constants.dart';

class AddEditScreen extends ConsumerStatefulWidget {
  final AlarmModel? existing;

  const AddEditScreen({super.key, this.existing});

  @override
  ConsumerState<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends ConsumerState<AddEditScreen> {
  late TimeOfDay _selectedTime;
  late TextEditingController _labelController;
  late List<int> _selectedDays;
  late String _selectedSound;
  late int _snoozeDuration;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final alarm = widget.existing;
    _selectedTime = alarm != null
        ? TimeOfDay(hour: alarm.hour, minute: alarm.minute)
        : TimeOfDay.now();
    _labelController = TextEditingController(text: alarm?.label ?? '');
    _selectedDays    = alarm?.repeatDaysList ?? [];
    _selectedSound   = alarm?.soundPath ??
        AppConstants.alarmSounds.values.first;
    _snoozeDuration  = alarm?.snoozeDuration ?? 5;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    bool success;
    final repeatDays = _selectedDays.join(',');

    if (_isEditing) {
      final updated = widget.existing!.copyWith(
        hour:           _selectedTime.hour,
        minute:         _selectedTime.minute,
        label:          _labelController.text.trim(),
        repeatDays:     repeatDays,
        soundPath:      _selectedSound,
        snoozeDuration: _snoozeDuration,
      );
      success = await ref.read(alarmProvider.notifier).updateAlarm(updated);
    } else {
      success = await ref.read(alarmProvider.notifier).addAlarm(
        hour:           _selectedTime.hour,
        minute:         _selectedTime.minute,
        label:          _labelController.text.trim(),
        repeatDays:     repeatDays,
        soundPath:      _selectedSound,
        snoozeDuration: _snoozeDuration,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.pop();
    } else {
      setState(() => _errorMessage = 'Failed to save alarm. Please try again.');
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final settings   = ref.watch(settingsProvider).value;
    final use24h     = settings?.use24HourFormat ?? false;
    final colorScheme = Theme.of(context).colorScheme;

    final timeDisplay = use24h
        ? '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'
        : _selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Alarm' : 'New Alarm'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Error banner ─────────────────────────────────────────────────
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: colorScheme.error, fontSize: 13),
              ),
            ),

          // ── Time ─────────────────────────────────────────────────────────
          GestureDetector(
            onTap: _pickTime,
            child: Center(
              child: Text(
                timeDisplay,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Tap to change time',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Label ─────────────────────────────────────────────────────────
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Label',
              hintText: 'e.g. Wake up, Gym, Meeting',
              prefixIcon: Icon(Icons.label_outline),
            ),
          ),
          const SizedBox(height: 24),

          // ── Repeat days ───────────────────────────────────────────────────
          Text('Repeat', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          DaySelector(
            selectedDays: _selectedDays,
            onChanged: (days) => setState(() => _selectedDays = days),
          ),
          const SizedBox(height: 24),

          // ── Sound ─────────────────────────────────────────────────────────
          Text('Alarm Sound', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          RadioGroup<String>(
            groupValue: _selectedSound,
            onChanged: (val) => setState(() => _selectedSound = val!),
            child: Column(
              children: AppConstants.alarmSounds.entries.map(
                    (e) => RadioListTile<String>(
                  title: Text(e.key),
                  value: e.value,
                  activeColor: colorScheme.primary,
                ),
              ).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // ── Snooze ────────────────────────────────────────────────────────
          Text('Snooze Duration', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            initialValue: _snoozeDuration,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.snooze),
            ),
            items: AppConstants.snoozeOptions
                .map((min) => DropdownMenuItem(
              value: min,
              child: Text('$min minutes'),
            ))
                .toList(),
            onChanged: (val) => setState(() => _snoozeDuration = val!),
          ),
          const SizedBox(height: 40),

          // ── Delete (edit mode only) ───────────────────────────────────────
          if (_isEditing)
            OutlinedButton.icon(
              onPressed: () async {
                await ref
                    .read(alarmProvider.notifier)
                    .deleteAlarm(widget.existing!.id);
                if (!context.mounted) return;
                context.pop();
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Delete Alarm',
                  style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}