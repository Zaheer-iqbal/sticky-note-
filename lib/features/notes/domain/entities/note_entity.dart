import 'package:sticky_notes/shared/utils/enums.dart';

class NoteEntity {
  final String id;
  String title;
  String description;
  String colorName;
  DateTime createdAt;
  DateTime? reminderDateTime;
  RepeatType repeatType;
  bool alarmEnabled;
  bool isPinned;
  NoteCategory category;

  NoteEntity({
    required this.id,
    required this.title,
    this.description = '',
    this.colorName = 'Yellow',
    DateTime? createdAt,
    this.reminderDateTime,
    this.repeatType = RepeatType.once,
    this.alarmEnabled = false,
    this.isPinned = false,
    this.category = NoteCategory.personal,
  }) : createdAt = createdAt ?? DateTime.now();
}
