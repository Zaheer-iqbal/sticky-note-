import 'package:hive_flutter/hive_flutter.dart';
import 'package:sticky_notes/core/constants/app_constants.dart';
import 'package:sticky_notes/core/models/note_model.dart';

class NoteLocalDataSource {
  final Box<NoteModel> _box;

  NoteLocalDataSource() : _box = Hive.box<NoteModel>(AppConstants.hiveBoxNotes);

  List<NoteModel> getAll() => _box.values.toList();

  List<NoteModel> getPinned() =>
      _box.values.where((n) => n.isPinned).toList();

  List<NoteModel> getUnpinned() =>
      _box.values.where((n) => !n.isPinned).toList();

  List<NoteModel> search(String query) {
    final q = query.toLowerCase();
    return _box.values
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.description.toLowerCase().contains(q))
        .toList();
  }

  List<NoteModel> getByCategory(String category) =>
      _box.values.where((n) => n.category == category).toList();

  NoteModel? getById(String id) {
    final idx = _box.values.toList().indexWhere((n) => n.id == id);
    if (idx == -1) return null;
    return _box.values.toList()[idx];
  }

  Future<void> add(NoteModel note) => _box.add(note);

  Future<void> update(NoteModel note) => note.save();

  Future<void> delete(String id) {
    final idx = _box.values.toList().indexWhere((n) => n.id == id);
    if (idx != -1) return _box.deleteAt(idx);
    return Future.value();
  }

  List<NoteModel> getWithReminders() =>
      _box.values.where((n) => n.reminderDateTime != null).toList();
}
