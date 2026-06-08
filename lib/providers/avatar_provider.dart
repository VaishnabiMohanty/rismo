import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

final avatarProvider =
AsyncNotifierProvider<AvatarNotifier, String?>(AvatarNotifier.new);

class AvatarNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('avatar_path');
  }

  // ── Pick from gallery ────────────────────────────────────────────────────────

  Future<void> pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    await _saveAvatar(File(picked.path));
  }

  // ── Pick from camera ─────────────────────────────────────────────────────────

  Future<void> pickFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (picked == null) return;
    await _saveAvatar(File(picked.path));
  }

  // ── Remove avatar ────────────────────────────────────────────────────────────

  Future<void> removeAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final currentPath = state.value;
    if (currentPath != null) {
      final file = File(currentPath);
      if (await file.exists()) await file.delete();
    }
    await prefs.remove('avatar_path');
    state = const AsyncData(null);
  }

  // ── Save helper ──────────────────────────────────────────────────────────────

  Future<void> _saveAvatar(File imageFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = await imageFile.copy(p.join(appDir.path, fileName));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_path', savedFile.path);

    state = AsyncData(savedFile.path);
  }
}