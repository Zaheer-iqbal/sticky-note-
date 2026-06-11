import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticky_notes/core/models/note_model.dart';
import 'package:sticky_notes/core/services/notification_service.dart';
import 'package:sticky_notes/features/notes/presentation/providers/note_provider.dart';
import 'package:sticky_notes/features/reminders/presentation/screens/full_screen_reminder.dart';

class ReminderChecker {
  Timer? _timer;
  final List<String> _triggeredIds = [];

  void start(WidgetRef ref, NavigatorState navigator) {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _check(ref, navigator);
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _check(WidgetRef ref, NavigatorState navigator) async {
    try {
      final repo = ref.read(noteRepositoryProvider);
      final allNotes = await repo.getAllNotes();
      final now = DateTime.now();

      for (final note in allNotes) {
        if (note.reminderDateTime == null) continue;
        if (_triggeredIds.contains(note.id)) continue;

        final diff = now.difference(note.reminderDateTime!);
        if (diff.inSeconds >= 0 && diff.inMinutes < 1) {
          _triggeredIds.add(note.id);
          await NotificationService.showReminderNotification(note);
          _showFullScreen(navigator, note);
        }
      }
    } catch (_) {}
  }

  void _showFullScreen(NavigatorState navigator, NoteModel note) {
    navigator.push(
      MaterialPageRoute(
        builder: (_) => FullScreenReminder(note: note),
        fullscreenDialog: true,
      ),
    );
  }

  void clearTriggered(String noteId) {
    _triggeredIds.remove(noteId);
  }
}
