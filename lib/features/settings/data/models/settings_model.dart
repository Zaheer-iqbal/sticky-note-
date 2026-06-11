import 'package:hive/hive.dart';

class SettingsModel extends HiveObject {
  bool isDarkMode;
  bool notificationsEnabled;
  String profileName;
  String profileImagePath;

  SettingsModel({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.profileName = 'Alex',
    this.profileImagePath = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'profileName': profileName,
      'profileImagePath': profileImagePath,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      profileName: json['profileName'] as String? ?? 'Alex',
      profileImagePath: json['profileImagePath'] as String? ?? '',
    );
  }
}

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 1;

  @override
  SettingsModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return SettingsModel(
      isDarkMode: fields[0] as bool? ?? false,
      notificationsEnabled: fields[1] as bool? ?? true,
      profileName: fields[2] as String? ?? 'Alex',
      profileImagePath: fields[3] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    final fields = <int, dynamic>{
      0: obj.isDarkMode,
      1: obj.notificationsEnabled,
      2: obj.profileName,
      3: obj.profileImagePath,
    };
    writer.writeByte(fields.length);
    for (final entry in fields.entries) {
      writer.writeByte(entry.key);
      writer.write(entry.value);
    }
  }
}
