import 'dart:convert';
import 'package:sticky_notes/core/models/note_model.dart';
import 'package:sticky_notes/features/notes/data/datasources/note_local_datasource.dart';
import 'package:sticky_notes/features/notes/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource _dataSource;

  NoteRepositoryImpl(this._dataSource);

  @override
  Future<List<NoteModel>> getAllNotes() async => _dataSource.getAll();

  @override
  Future<List<NoteModel>> getPinnedNotes() async => _dataSource.getPinned();

  @override
  Future<List<NoteModel>> getUnpinnedNotes() async =>
      _dataSource.getUnpinned();

  @override
  Future<List<NoteModel>> searchNotes(String query) async =>
      _dataSource.search(query);

  @override
  Future<List<NoteModel>> getNotesByCategory(String category) async =>
      _dataSource.getByCategory(category);

  @override
  Future<NoteModel?> getNoteById(String id) async =>
      _dataSource.getById(id);

  @override
  Future<void> addNote(NoteModel note) async => _dataSource.add(note);

  @override
  Future<void> updateNote(NoteModel note) async => _dataSource.update(note);

  @override
  Future<void> deleteNote(String id) async => _dataSource.delete(id);

  @override
  Future<void> togglePin(String id) async {
    final note = _dataSource.getById(id);
    if (note != null) {
      note.isPinned = !note.isPinned;
      await note.save();
    }
  }

  @override
  Future<void> toggleAlarm(String id) async {
    final note = _dataSource.getById(id);
    if (note != null) {
      note.alarmEnabled = !note.alarmEnabled;
      await note.save();
    }
  }

  @override
  Future<List<NoteModel>> getNotesWithReminders() async =>
      _dataSource.getWithReminders();

  @override
  Future<String> exportToJson() async {
    final notes = _dataSource.getAll();
    final jsonList = notes.map((n) => n.toJson()).toList();
    return jsonEncode(jsonList);
  }

  @override
  Future<void> importFromJson(String json) async {
    final list = jsonDecode(json) as List;
    for (final item in list) {
      final note = NoteModel.fromJson(item as Map<String, dynamic>);
      await _dataSource.add(note);
    }
  }
}
