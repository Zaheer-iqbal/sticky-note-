import 'dart:convert';
import 'package:sticky_notes/core/models/note_model.dart';
import 'package:sticky_notes/features/notes/data/datasources/note_local_datasource.dart';
import 'package:sticky_notes/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:sticky_notes/features/settings/data/models/settings_model.dart';
import 'package:sticky_notes/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _dataSource;
  final NoteLocalDataSource _noteDataSource;

  SettingsRepositoryImpl(this._dataSource, this._noteDataSource);

  @override
  SettingsModel getSettings() => _dataSource.getSettings();

  @override
  Future<void> updateSettings(SettingsModel settings) async =>
      _dataSource.updateSettings(settings);

  @override
  Future<void> toggleDarkMode() async => _dataSource.toggleDarkMode();

  @override
  Future<void> toggleNotifications() async =>
      _dataSource.toggleNotifications();

  @override
  Future<String> exportBackup() async {
    final notes = _noteDataSource.getAll();
    final settings = _dataSource.getSettings();
    final backup = {
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings.toJson(),
      'notes': notes.map((n) => n.toJson()).toList(),
    };
    return jsonEncode(backup);
  }

  @override
  Future<void> importBackup(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    if (data['notes'] != null) {
      final notes = data['notes'] as List;
      for (final item in notes) {
        final note = NoteModel.fromJson(item as Map<String, dynamic>);
        await _noteDataSource.add(note);
      }
    }
    if (data['settings'] != null) {
      final settings =
          SettingsModel.fromJson(data['settings'] as Map<String, dynamic>);
      await _dataSource.updateSettings(settings);
    }
  }
}
