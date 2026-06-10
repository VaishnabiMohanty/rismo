import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) {
          // Guard: ensure current sound value exists in items list
          final soundValue =
          AppConstants.alarmSounds.values.contains(settings.defaultSoundPath)
              ? settings.defaultSoundPath
              : AppConstants.alarmSounds.values.first;

          return ListView(
            children: [
              // ── Appearance ────────────────────────────────────────────────
              const _SectionHeader(title: 'Appearance'),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Theme'),
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(value: ThemeMode.light,  child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark,   child: Text('Dark')),
                  ],
                  onChanged: (val) =>
                      ref.read(settingsProvider.notifier).setThemeMode(val!),
                ),
              ),

              // ── Clock ──────────────────────────────────────────────────────
              const _SectionHeader(title: 'Clock'),
              SwitchListTile(
                secondary: const Icon(Icons.access_time),
                title: const Text('24-hour format'),
                subtitle: const Text('Show time as 14:30 instead of 2:30 PM'),
                value: settings.use24HourFormat,
                onChanged: (val) =>
                    ref.read(settingsProvider.notifier).setTimeFormat(val),
              ),

              // ── Alarm defaults ─────────────────────────────────────────────
              const _SectionHeader(title: 'Alarm Defaults'),
              ListTile(
                leading: const Icon(Icons.snooze),
                title: const Text('Default Snooze Duration'),
                trailing: DropdownButton<int>(
                  value: settings.defaultSnoozeDuration,
                  underline: const SizedBox(),
                  items: AppConstants.snoozeOptions
                      .map((min) => DropdownMenuItem(
                    value: min,
                    child: Text('$min min'),
                  ))
                      .toList(),
                  onChanged: (val) =>
                      ref.read(settingsProvider.notifier).setSnoozeDuration(val!),
                ),
              ),

              // ── Default sound — safe dropdown ──────────────────────────────
              ListTile(
                leading: const Icon(Icons.music_note_outlined),
                title: const Text('Default Alarm Sound'),
                trailing: DropdownButton<String>(
                  value: soundValue, // ← always a valid value
                  underline: const SizedBox(),
                  items: AppConstants.alarmSounds.entries
                      .map((e) => DropdownMenuItem(
                    value: e.value,
                    child: Text(e.key),
                  ))
                      .toList(),
                  onChanged: (val) =>
                      ref.read(settingsProvider.notifier).setDefaultSound(val!),
                ),
              ),

              // ── Profile ────────────────────────────────────────────────────
              const _SectionHeader(title: 'Profile'),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Your Name'),
                subtitle: Text(
                  settings.userName.isEmpty ? 'Not set' : settings.userName,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showNameDialog(context, ref, settings.userName),
              ),

              // ── About ──────────────────────────────────────────────────────
              const _SectionHeader(title: 'About'),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('App'),
                trailing: Text('Rismo v1.0.0',
                    style: TextStyle(color: Colors.grey)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showNameDialog(BuildContext context, WidgetRef ref, String current) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Your Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref
                  .read(settingsProvider.notifier)
                  .setUserName(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}