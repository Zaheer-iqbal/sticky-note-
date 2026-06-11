import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticky_notes/core/models/note_model.dart';
import 'package:sticky_notes/features/notes/presentation/providers/note_provider.dart';

final dueRemindersProvider = FutureProvider<List<NoteModel>>((ref) async {
  final notes = await ref.watch(notesWithRemindersProvider.future);
  final now = DateTime.now();
  return notes.where((n) {
    if (n.reminderDateTime == null) return false;
    return n.reminderDateTime!.isBefore(now) ||
        n.reminderDateTime!.difference(now).inMinutes <= 1;
  }).toList();
});

final upcomingRemindersProvider = FutureProvider<List<NoteModel>>((ref) async {
  final notes = await ref.watch(notesWithRemindersProvider.future);
  final now = DateTime.now();
  return notes.where((n) {
    if (n.reminderDateTime == null) return false;
    return n.reminderDateTime!.isAfter(now);
  }).toList()
    ..sort((a, b) => a.reminderDateTime!.compareTo(b.reminderDateTime!));
});
