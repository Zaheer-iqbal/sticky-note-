import 'package:flutter/material.dart';
import 'package:sticky_notes/core/constants/note_colors.dart';

class ColorPickerWidget extends StatelessWidget {
  final String selectedColor;
  final ValueChanged<String> onColorSelected;

  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: NoteColors.colors.entries.map((entry) {
        final isSelected = entry.key == selectedColor;
        return GestureDetector(
          onTap: () => onColorSelected(entry.key),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: entry.value,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.black87, width: 3)
                  : Border.all(color: Colors.grey.shade300),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: entry.value.withAlpha(128),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.black87, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
