import 'package:sticky_notes/core/models/note_model.dart';

abstract class NoteRepository {
  Future<List<NoteModel>> getAllNotes();
  Future<List<NoteModel>> getPinnedNotes();
  Future<List<NoteModel>> getUnpinnedNotes();
  Future<List<NoteModel>> searchNotes(String query);
  Future<List<NoteModel>> getNotesByCategory(String category);
  Future<NoteModel?> getNoteById(String id);
  Future<void> addNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
  Future<void> togglePin(String id);
  Future<void> toggleAlarm(String id);
  Future<List<NoteModel>> getNotesWithReminders();
  Future<String> exportToJson();
  Future<void> importFromJson(String json);
}
