import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class EditProfileDialog extends StatefulWidget {
  final String currentName;
  final String currentImagePath;
  final Function(String, String) onSave;

  const EditProfileDialog({
    super.key,
    required this.currentName,
    required this.currentImagePath,
    required this.onSave,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late String _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _imagePath = widget.currentImagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _imagePath = result.files.single.path!;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCustomImage = _imagePath.isNotEmpty;
    ImageProvider? imageProvider;
    if (hasCustomImage) {
      if (_imagePath.startsWith('http') || _imagePath.startsWith('https')) {
        imageProvider = NetworkImage(_imagePath);
      } else {
        imageProvider = FileImage(File(_imagePath));
      }
    }

    return AlertDialog(
      title: const Text(
        'Edit Profile',
        style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar Preview
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: const Color(0xFF7C3AED).withAlpha(51),
                    backgroundImage: imageProvider,
                    child: !hasCustomImage
                        ? const Icon(Icons.person, size: 44, color: Color(0xFF7C3AED))
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF7C3AED),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: const TextStyle(fontFamily: 'Manrope'),
                hintText: 'Enter your name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Image URL option
            TextField(
              onChanged: (val) {
                setState(() {
                  _imagePath = val.trim();
                });
              },
              decoration: InputDecoration(
                labelText: 'Or enter Image URL',
                labelStyle: const TextStyle(fontFamily: 'Manrope'),
                hintText: 'https://example.com/avatar.png',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(fontFamily: 'Manrope')),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Name cannot be empty')),
              );
              return;
            }
            widget.onSave(name, _imagePath);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
          ),
          child: const Text('Save', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
