import 'package:hive/hive.dart';

class NoteModel extends HiveObject {
  final String id;
  String title;
  String description;
  String colorName;
  DateTime createdAt;
  DateTime? reminderDateTime;
  String repeatType;
  bool alarmEnabled;
  bool isPinned;
  String category;

  NoteModel({
    required this.id,
    required this.title,
    this.description = '',
    this.colorName = 'Yellow',
    DateTime? createdAt,
    this.reminderDateTime,
    this.repeatType = 'once',
    this.alarmEnabled = false,
    this.isPinned = false,
    this.category = 'personal',
  }) : createdAt = createdAt ?? DateTime.now();

  NoteModel copyWith({
    String? id,
    String? title,
    String? description,
    String? colorName,
    DateTime? createdAt,
    DateTime? reminderDateTime,
    String? repeatType,
    bool? alarmEnabled,
    bool? isPinned,
    String? category,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      colorName: colorName ?? this.colorName,
      createdAt: createdAt ?? this.createdAt,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      repeatType: repeatType ?? this.repeatType,
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
      isPinned: isPinned ?? this.isPinned,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'colorName': colorName,
      'createdAt': createdAt.toIso8601String(),
      'reminderDateTime': reminderDateTime?.toIso8601String(),
      'repeatType': repeatType,
      'alarmEnabled': alarmEnabled,
      'isPinned': isPinned,
      'category': category,
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      colorName: json['colorName'] as String? ?? 'Yellow',
      createdAt: DateTime.parse(json['createdAt'] as String),
      reminderDateTime: json['reminderDateTime'] != null
          ? DateTime.parse(json['reminderDateTime'] as String)
          : null,
      repeatType: json['repeatType'] as String? ?? 'once',
      alarmEnabled: json['alarmEnabled'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      category: json['category'] as String? ?? 'personal',
    );
  }
}

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 0;

  @override
  NoteModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return NoteModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String? ?? '',
      colorName: fields[3] as String? ?? 'Yellow',
      createdAt: fields[4] as DateTime? ?? DateTime.now(),
      reminderDateTime: fields[5] as DateTime?,
      repeatType: fields[6] as String? ?? 'once',
      alarmEnabled: fields[7] as bool? ?? false,
      isPinned: fields[8] as bool? ?? false,
      category: fields[9] as String? ?? 'personal',
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    final fields = <int, dynamic>{
      0: obj.id,
      1: obj.title,
      2: obj.description,
      3: obj.colorName,
      4: obj.createdAt,
      5: obj.reminderDateTime,
      6: obj.repeatType,
      7: obj.alarmEnabled,
      8: obj.isPinned,
      9: obj.category,
    };
    writer.writeByte(fields.length);
    for (final entry in fields.entries) {
      writer.writeByte(entry.key);
      writer.write(entry.value);
    }
  }
}
