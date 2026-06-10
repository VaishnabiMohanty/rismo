import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/avatar_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/persistent_mascot.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarPath = ref.watch(avatarProvider).value;
    final streakAsync = ref.watch(streakNotifierProvider);
    final settings = ref.watch(settingsProvider).value;
    final userName = settings?.userName ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            children: [
              // ── Avatar ─────────────────────────────────────────────────
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: avatarPath != null
                          ? FileImage(File(avatarPath))
                          : null,
                      child: avatarPath == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showAvatarOptions(context, ref),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor:
                          Theme.of(context).colorScheme.primary,
                          child: const Icon(Icons.camera_alt,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: Text(
                  userName.isEmpty ? 'Set your name in Settings' : userName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),

              // ── Streak stats ───────────────────────────────────────────
              streakAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox(),
                data: (streak) => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Stat(label: 'Streak', value: '${streak.currentStreak}🔥'),
                      _Divider(),
                      _Stat(label: 'Best', value: '${streak.bestStreak}🏆'),
                      _Divider(),
                      _Stat(label: 'Wakes', value: '${streak.wakeHistory.length}⏰'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Actions ────────────────────────────────────────────────
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                leading: const Icon(Icons.bar_chart),
                title: const Text('View Full Stats'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/stats'),
              ),
              const SizedBox(height: 12),
              if (avatarPath != null)
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  tileColor: Colors.red.withValues(alpha: 0.08),
                  leading:
                  const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Remove Photo',
                      style: TextStyle(color: Colors.red)),
                  onTap: () =>
                      ref.read(avatarProvider.notifier).removeAvatar(),
                ),
            ],
          ),

          // ── Mascot ────────────────────────────────────────────────────
          const Positioned(
            left: 0,
            bottom: 16,
            child: PersistentMascot(context: MascotContext.profile),
          ),
        ],
      ),
    );
  }

  void _showAvatarOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                ref.read(avatarProvider.notifier).pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                ref.read(avatarProvider.notifier).pickFromCamera();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.55),
          )),
    ],
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 36,
    width: 1,
    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
  );
}