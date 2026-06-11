import 'package:flutter/material.dart';
import 'package:sticky_notes/core/models/note_model.dart';
import 'package:sticky_notes/shared/utils/enums.dart';
import 'package:sticky_notes/shared/widgets/category_selector.dart';
import 'package:sticky_notes/shared/widgets/color_picker_widget.dart';
import 'package:uuid/uuid.dart';

class NoteFormDialog extends StatefulWidget {
  final NoteModel? note;

  const NoteFormDialog({super.key, this.note});

  @override
  State<NoteFormDialog> createState() => _NoteFormDialogState();
}

class _NoteFormDialogState extends State<NoteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedColor;
  late String _selectedCategory;
  late bool _alarmEnabled;
  late String _repeatType;
  DateTime? _reminderDateTime;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.note != null;
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.note?.description ?? '');
    _selectedColor = widget.note?.colorName ?? 'Yellow';
    _selectedCategory = widget.note?.category ?? 'personal';
    _alarmEnabled = widget.note?.alarmEnabled ?? false;
    _repeatType = widget.note?.repeatType ?? 'once';
    _reminderDateTime = widget.note?.reminderDateTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderDateTime ?? now.add(const Duration(minutes: 10)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _reminderDateTime ?? now.add(const Duration(minutes: 10)),
      ),
    );
    if (time == null || !mounted) return;
    setState(() {
      _reminderDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final note = NoteModel(
      id: _isEditing ? widget.note!.id : const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      colorName: _selectedColor,
      createdAt: _isEditing ? widget.note!.createdAt : DateTime.now(),
      reminderDateTime: _reminderDateTime,
      repeatType: _repeatType,
      alarmEnabled: _alarmEnabled,
      isPinned: _isEditing ? widget.note!.isPinned : false,
      category: _selectedCategory,
    );

    Navigator.of(context).pop(note);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Edit Note' : 'New Note',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter note title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter note description',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                minLines: 2,
              ),
              const SizedBox(height: 20),
              const Text(
                'Color',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ColorPickerWidget(
                selectedColor: _selectedColor,
                onColorSelected: (c) => setState(() => _selectedColor = c),
              ),
              const SizedBox(height: 20),
              const Text(
                'Category',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CategorySelector(
                selectedCategory: _selectedCategory,
                onCategorySelected: (c) =>
                    setState(() => _selectedCategory = c),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Set Reminder'),
                value: _reminderDateTime != null,
                onChanged: (v) {
                  if (v) {
                    _pickDateTime();
                  } else {
                    setState(() => _reminderDateTime = null);
                  }
                },
                contentPadding: EdgeInsets.zero,
              ),
              if (_reminderDateTime != null) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    '${_reminderDateTime!.day}/${_reminderDateTime!.month}/${_reminderDateTime!.year} '
                    '${_reminderDateTime!.hour.toString().padLeft(2, '0')}:'
                    '${_reminderDateTime!.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: TextButton(
                    onPressed: _pickDateTime,
                    child: const Text('Change'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Repeat',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: RepeatType.values.map((r) {
                    final isSelected = r.name == _repeatType;
                    return ChoiceChip(
                      label: Text(r.label),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _repeatType = r.name),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Enable Alarm Sound'),
                  subtitle: const Text('Play sound and vibrate'),
                  value: _alarmEnabled,
                  onChanged: (v) => setState(() => _alarmEnabled = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Update Note' : 'Create Note',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
