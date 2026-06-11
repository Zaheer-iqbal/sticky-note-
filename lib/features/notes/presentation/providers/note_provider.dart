import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticky_notes/core/models/note_model.dart';
import 'package:sticky_notes/features/notes/data/datasources/note_local_datasource.dart';
import 'package:sticky_notes/features/notes/data/repositories/note_repository_impl.dart';
import 'package:sticky_notes/features/notes/domain/repositories/note_repository.dart';

final noteDataSourceProvider = Provider<NoteLocalDataSource>((ref) {
  return NoteLocalDataSource();
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final dataSource = ref.watch(noteDataSourceProvider);
  return NoteRepositoryImpl(dataSource);
});

final allNotesProvider = FutureProvider<List<NoteModel>>((ref) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.getAllNotes();
});

final pinnedNotesProvider = FutureProvider<List<NoteModel>>((ref) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.getPinnedNotes();
});

final unpinnedNotesProvider = FutureProvider<List<NoteModel>>((ref) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.getUnpinnedNotes();
});

final searchNotesProvider =
    FutureProvider.family<List<NoteModel>, String>((ref, query) async {
  final repo = ref.watch(noteRepositoryProvider);
  if (query.isEmpty) return repo.getAllNotes();
  return repo.searchNotes(query);
});

final notesByCategoryProvider =
    FutureProvider.family<List<NoteModel>, String>((ref, category) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.getNotesByCategory(category);
});

final notesWithRemindersProvider = FutureProvider<List<NoteModel>>((ref) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.getNotesWithReminders();
});

class NoteNotifier extends StateNotifier<AsyncValue<List<NoteModel>>> {
  final NoteRepository _repository;

  NoteNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllNotes());
  }

  Future<void> addNote(NoteModel note) async {
    await _repository.addNote(note);
    await loadNotes();
  }

  Future<void> updateNote(NoteModel note) async {
    await _repository.updateNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _repository.deleteNote(id);
    await loadNotes();
  }

  Future<void> togglePin(String id) async {
    await _repository.togglePin(id);
    await loadNotes();
  }
}

final noteNotifierProvider =
    StateNotifierProvider<NoteNotifier, AsyncValue<List<NoteModel>>>((ref) {
  final repo = ref.watch(noteRepositoryProvider);
  return NoteNotifier(repo);
});
