import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/avatar_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/settings_provider.dart';

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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── Avatar ───────────────────────────────────────────────────────────
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                  avatarPath != null ? FileImage(File(avatarPath)) : null,
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
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Name ─────────────────────────────────────────────────────────────
          Center(
            child: Text(
              userName.isEmpty ? 'Set your name in Settings' : userName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ── Streak summary ───────────────────────────────────────────────────
          streakAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox(),
            data: (streak) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ProfileStat(
                  label: 'Current Streak',
                  value: '${streak.currentStreak}🔥',
                ),
                _ProfileStat(
                  label: 'Best Streak',
                  value: '${streak.bestStreak}🏆',
                ),
                _ProfileStat(
                  label: 'Total Wakes',
                  value: '${streak.wakeHistory.length}⏰',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Actions ──────────────────────────────────────────────────────────
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: Theme.of(context).colorScheme.surfaceVariant,
            leading: const Icon(Icons.bar_chart),
            title: const Text('View Full Stats'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/stats'),
          ),
          const SizedBox(height: 12),
          if (avatarPath != null)
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.red.withOpacity(0.08),
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Remove Photo',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () =>
                  ref.read(avatarProvider.notifier).removeAvatar(),
            ),
        ],
      ),
    );
  }

  // ── Avatar options bottom sheet ───────────────────────────────────────────────

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

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onBackground
                .withOpacity(0.55),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}