import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticky_notes/features/notes/presentation/providers/note_provider.dart';
import 'package:sticky_notes/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:sticky_notes/features/settings/data/models/settings_model.dart';
import 'package:sticky_notes/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:sticky_notes/features/settings/domain/repositories/settings_repository.dart';

final settingsDataSourceProvider = Provider<SettingsLocalDataSource>((ref) {
  return SettingsLocalDataSource();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dataSource = ref.watch(settingsDataSourceProvider);
  final noteDataSource = ref.watch(noteDataSourceProvider);
  return SettingsRepositoryImpl(dataSource, noteDataSource);
});

final settingsProvider = Provider<SettingsModel>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.getSettings();
});

final isDarkModeProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.isDarkMode;
});

class SettingsNotifier extends StateNotifier<SettingsModel> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(_repository.getSettings());

  Future<void> toggleDarkMode() async {
    await _repository.toggleDarkMode();
    state = _repository.getSettings();
  }

  Future<void> toggleNotifications() async {
    await _repository.toggleNotifications();
    state = _repository.getSettings();
  }

  Future<String> exportBackup() async => _repository.exportBackup();

  Future<void> importBackup(String json) async {
    await _repository.importBackup(json);
    state = _repository.getSettings();
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});
