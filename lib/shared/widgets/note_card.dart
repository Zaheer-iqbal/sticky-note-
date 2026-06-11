import 'package:flutter/material.dart';
import 'package:sticky_notes/core/constants/note_colors.dart';
import 'package:sticky_notes/core/models/note_model.dart';
import 'package:sticky_notes/shared/utils/date_utils.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback? onTap;
  final VoidCallback? onPin;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onPin,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = NoteColors.fromName(note.colorName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? _darken(color) : color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.isPinned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(20),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.push_pin, size: 14, color: isDark ? Colors.white70 : Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      'Pinned',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, note.isPinned ? 12 : 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (note.alarmEnabled)
                        Icon(
                          Icons.alarm,
                          size: 18,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                    ],
                  ),
                  if (note.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      note.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (note.reminderDateTime != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            DateFormatUtils.formatDateTime(note.reminderDateTime!),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onPin != null)
                        _ActionButton(
                          icon: note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                          onTap: onPin,
                          isDark: isDark,
                        ),
                      const SizedBox(width: 4),
                      if (onDelete != null)
                        _ActionButton(
                          icon: Icons.delete_outline,
                          onTap: onDelete,
                          isDark: isDark,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _darken(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness * 0.35).clamp(0.0, 0.5)).toColor();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
      ),
    );
  }
}
