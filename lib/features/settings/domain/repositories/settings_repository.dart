import 'package:sticky_notes/features/settings/data/models/settings_model.dart';

abstract class SettingsRepository {
  SettingsModel getSettings();
  Future<void> updateSettings(SettingsModel settings);
  Future<void> toggleDarkMode();
  Future<void> toggleNotifications();
  Future<String> exportBackup();
  Future<void> importBackup(String json);
}
