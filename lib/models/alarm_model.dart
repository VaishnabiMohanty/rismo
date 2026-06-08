import 'package:floor/floor.dart';

@entity
class AlarmModel {
  @primaryKey
  final String id;

  final int hour;
  final int minute;
  final String label;
  final String repeatDays;
  final bool isEnabled;
  final String soundPath;
  final int snoozeDuration;
  final int streakCount;
  final String? avatarPath;

  const AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    required this.label,
    required this.repeatDays,
    required this.isEnabled,
    required this.soundPath,
    required this.snoozeDuration,
    required this.streakCount,
    this.avatarPath,
  });

  List<int> get repeatDaysList {
    if (repeatDays.isEmpty) return [];
    return repeatDays.split(',').map(int.parse).toList();
  }

  bool get isRepeating => repeatDays.isNotEmpty;

  String get repeatLabel {
    if (repeatDays.isEmpty) return 'One-time';
    const dayNames = {
      1: 'Mon', 2: 'Tue', 3: 'Wed',
      4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun',
    };
    return repeatDaysList.map((d) => dayNames[d]).join(', ');
  }

  String get timeLabel {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get timeLabelAmPm {
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  AlarmModel copyWith({
    String? id,
    int? hour,
    int? minute,
    String? label,
    String? repeatDays,
    bool? isEnabled,
    String? soundPath,
    int? snoozeDuration,
    int? streakCount,
    String? avatarPath,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      label: label ?? this.label,
      repeatDays: repeatDays ?? this.repeatDays,
      isEnabled: isEnabled ?? this.isEnabled,
      soundPath: soundPath ?? this.soundPath,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
      streakCount: streakCount ?? this.streakCount,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AlarmModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}