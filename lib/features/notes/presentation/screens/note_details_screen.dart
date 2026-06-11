import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:sticky_notes/core/models/note_model.dart';
import 'package:sticky_notes/features/notes/presentation/providers/note_provider.dart';
import 'package:sticky_notes/core/constants/note_colors.dart';

class NoteDetailsScreen extends ConsumerStatefulWidget {
  final String noteId;
  final NoteModel? initialNote;

  const NoteDetailsScreen({
    super.key,
    required this.noteId,
    this.initialNote,
  });

  @override
  ConsumerState<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends ConsumerState<NoteDetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _colorName;
  late String _category;
  late bool _isPinned;
  late bool _alarmEnabled;
  late bool _hasReminder;
  late String _repeatType;
  DateTime? _reminderDateTime;

  bool get _isNew => widget.noteId == 'new';

  @override
  void initState() {
    super.initState();
    final note = widget.initialNote;

    _titleController = TextEditingController(text: note?.title ?? '');
    _descriptionController = TextEditingController(text: note?.description ?? '');
    _colorName = note?.colorName ?? 'Yellow';
    _category = note?.category ?? 'personal';
    _isPinned = note?.isPinned ?? false;
    _alarmEnabled = note?.alarmEnabled ?? false;
    _reminderDateTime = note?.reminderDateTime;
    _hasReminder = note?.reminderDateTime != null;
    _repeatType = note?.repeatType ?? 'once';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    final note = NoteModel(
      id: _isNew ? const Uuid().v4() : widget.noteId,
      title: title,
      description: _descriptionController.text.trim(),
      colorName: _colorName,
      createdAt: widget.initialNote?.createdAt ?? DateTime.now(),
      reminderDateTime: _hasReminder ? (_reminderDateTime ?? DateTime.now().add(const Duration(hours: 1))) : null,
      alarmEnabled: _alarmEnabled,
      isPinned: _isPinned,
      category: _category,
      repeatType: _repeatType,
    );

    if (_isNew) {
      ref.read(noteNotifierProvider.notifier).addNote(note);
    } else {
      ref.read(noteNotifierProvider.notifier).updateNote(note);
    }

    context.pop();
  }

  void _delete() {
    if (!_isNew) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(noteNotifierProvider.notifier).deleteNote(widget.noteId);
                Navigator.pop(ctx);
                context.pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }

  void _share() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    Share.share('$title\n\n$description');
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final current = _reminderDateTime ?? now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _reminderDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          current.hour,
          current.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final now = DateTime.now();
    final current = _reminderDateTime ?? now;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );

    if (pickedTime != null && mounted) {
      setState(() {
        _reminderDateTime = DateTime(
          current.year,
          current.month,
          current.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayDate = _reminderDateTime ?? DateTime.now();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1C30)),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          _isNew ? 'New Note' : 'Note Details',
          style: const TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFF7C3AED),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
            ),
            onPressed: () => setState(() => _isPinned = !_isPinned),
          ),
          if (!_isNew) ...[
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Color(0xFF64748B)),
              onPressed: _share,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _delete,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input
            TextField(
              controller: _titleController,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B1C30),
              ),
              decoration: const InputDecoration(
                hintText: 'Note Title',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 8),
            // Description input
            TextField(
              controller: _descriptionController,
              maxLines: 6,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
              decoration: const InputDecoration(
                hintText: 'Start typing your description here...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 24),

            // Note Color selection
            const Text(
              'Note Color',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B1C30),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: NoteColors.colors.entries.map((entry) {
                  final isSelected = entry.key.toLowerCase() == _colorName.toLowerCase();
                  return GestureDetector(
                    onTap: () => setState(() => _colorName = entry.key),
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: entry.value,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: const Color(0xFF7C3AED), width: 3)
                            : Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Set Reminder Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.alarm, color: Color(0xFF7C3AED)),
                          SizedBox(width: 8),
                          Text(
                            'Set Reminder',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B1C30),
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _hasReminder,
                        activeColor: const Color(0xFF7C3AED),
                        onChanged: (val) {
                          setState(() {
                            _hasReminder = val;
                            if (val) {
                              _alarmEnabled = true;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  if (_hasReminder) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DATE',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: _selectDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('MM/dd/yyyy').format(displayDate),
                                        style: const TextStyle(fontFamily: 'Manrope', fontSize: 13),
                                      ),
                                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF64748B)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TIME',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: _selectTime,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('hh:mm a').format(displayDate),
                                        style: const TextStyle(fontFamily: 'Manrope', fontSize: 13),
                                      ),
                                      const Icon(Icons.access_time, size: 16, color: Color(0xFF64748B)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'REPEAT OPTION',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['once', 'daily', 'weekly', 'monthly'].map((type) {
                        final isSelected = _repeatType == type;
                        final label = type[0].toUpperCase() + type.substring(1);
                        return GestureDetector(
                          onTap: () => setState(() => _repeatType = type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF7C3AED)
                                  : const Color(0xFFE5EEFF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 13,
                                color: isSelected ? Colors.white : const Color(0xFF4F46E5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notebook/Pen drawing illustration matching image no 2
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book, size: 48, color: const Color(0xFF7C3AED).withAlpha(128)),
                    const SizedBox(height: 8),
                    const Text(
                      'Ready to note down your thoughts.',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline),
                    const SizedBox(width: 8),
                    Text(
                      _isNew ? 'Save Note' : 'Update Note',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
