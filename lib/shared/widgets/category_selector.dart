import 'package:flutter/material.dart';
import 'package:sticky_notes/shared/utils/enums.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const categoryIcons = {
    'Personal': Icons.person,
    'Study': Icons.school,
    'Work': Icons.work,
    'Health': Icons.favorite,
    'Finance': Icons.attach_money,
    'Custom': Icons.label,
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: NoteCategory.values.map((category) {
        final label = category.label;
        final isSelected = label.toLowerCase() == selectedCategory.toLowerCase();
        return FilterChip(
          selected: isSelected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                categoryIcons[label] ?? Icons.label,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(label),
            ],
          ),
          onSelected: (_) => onCategorySelected(label.toLowerCase()),
          selectedColor: const Color(0xFFFFC107).withAlpha(51),
          checkmarkColor: const Color(0xFFFFC107),
        );
      }).toList(),
    );
  }
}
