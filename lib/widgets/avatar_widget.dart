import 'dart:io';
import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatarPath; // local file path, null = show placeholder
  final double radius;
  final VoidCallback? onTap;
  final bool showEditIcon;

  const AvatarWidget({
    super.key,
    required this.avatarPath,
    this.radius = 40,
    this.onTap,
    this.showEditIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // ── Avatar circle ──────────────────────────────────────────────────
          CircleAvatar(
            radius: radius,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage:
            avatarPath != null ? FileImage(File(avatarPath!)) : null,
            child: avatarPath == null
                ? Icon(
              Icons.person,
              size: radius * 0.9,
              color: colorScheme.onPrimaryContainer,
            )
                : null,
          ),

          // ── Edit icon overlay ──────────────────────────────────────────────
          if (showEditIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: radius * 0.6,
                height: radius * 0.6,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.onSurface,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: radius * 0.3,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}