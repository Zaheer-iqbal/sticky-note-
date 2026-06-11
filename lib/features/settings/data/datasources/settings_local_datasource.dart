import 'package:hive_flutter/hive_flutter.dart';
import 'package:sticky_notes/core/constants/app_constants.dart';
import 'package:sticky_notes/features/settings/data/models/settings_model.dart';

class SettingsLocalDataSource {
  final Box<SettingsModel> _box;

  SettingsLocalDataSource()
      : _box = Hive.box<SettingsModel>(AppConstants.hiveBoxSettings);

  SettingsModel getSettings() {
    if (_box.isEmpty) {
      final settings = SettingsModel();
      _box.add(settings);
      return settings;
    }
    return _box.values.first;
  }

  Future<void> updateSettings(SettingsModel settings) async {
    await settings.save();
  }

  Future<void> toggleDarkMode() async {
    final settings = getSettings();
    settings.isDarkMode = !settings.isDarkMode;
    await settings.save();
  }

  Future<void> toggleNotifications() async {
    final settings = getSettings();
    settings.notificationsEnabled = !settings.notificationsEnabled;
    await settings.save();
  }
}
