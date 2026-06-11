import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sticky_notes/features/notes/presentation/providers/note_provider.dart';
import 'package:sticky_notes/shared/utils/date_utils.dart';
import 'package:sticky_notes/shared/widgets/empty_state.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(noteNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notes) {
          final reminders = notes.where((n) => n.reminderDateTime != null).toList()
            ..sort((a, b) => a.reminderDateTime!.compareTo(b.reminderDateTime!));

          if (reminders.isEmpty) {
            return EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'No Reminders',
              subtitle: 'Create a note and set a reminder to see it here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final note = reminders[index];
              final isOverdue = note.reminderDateTime!.isBefore(DateTime.now());

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE5EEFF)),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: const Border(
                      left: BorderSide(
                        color: Color(0xFFF59E0B),
                        width: 4,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            note.title,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (note.alarmEnabled)
                          const Icon(Icons.alarm, color: Color(0xFFF59E0B), size: 18),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          note.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: isOverdue ? Colors.red : const Color(0xFF7C3AED),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormatUtils.formatDateTime(note.reminderDateTime!),
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isOverdue ? Colors.red : const Color(0xFF7C3AED),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () => context.push('/note-details/${note.id}', extra: note),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
