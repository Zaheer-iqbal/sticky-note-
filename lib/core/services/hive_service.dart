import 'package:hive_flutter/hive_flutter.dart';
import 'package:sticky_notes/core/constants/app_constants.dart';
import 'package:sticky_notes/core/models/note_model.dart';
import 'package:sticky_notes/features/settings/data/models/settings_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());
    await Hive.openBox<NoteModel>(AppConstants.hiveBoxNotes);
    await Hive.openBox<SettingsModel>(AppConstants.hiveBoxSettings);
  }

  static Box<NoteModel> get notesBox =>
      Hive.box<NoteModel>(AppConstants.hiveBoxNotes);

  static Box<SettingsModel> get settingsBox =>
      Hive.box<SettingsModel>(AppConstants.hiveBoxSettings);
}
