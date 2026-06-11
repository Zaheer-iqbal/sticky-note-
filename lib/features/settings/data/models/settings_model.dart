import 'package:hive/hive.dart';

class SettingsModel extends HiveObject {
  bool isDarkMode;
  bool notificationsEnabled;

  SettingsModel({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
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
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    final fields = <int, dynamic>{
      0: obj.isDarkMode,
      1: obj.notificationsEnabled,
    };
    writer.writeByte(fields.length);
    for (final entry in fields.entries) {
      writer.writeByte(entry.key);
      writer.write(entry.value);
    }
  }
}
