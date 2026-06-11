import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticky_notes/core/constants/note_colors.dart';
import 'package:sticky_notes/core/models/note_model.dart';
import 'package:sticky_notes/shared/utils/date_utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class FullScreenReminder extends ConsumerStatefulWidget {
  final NoteModel note;

  const FullScreenReminder({super.key, required this.note});

  @override
  ConsumerState<FullScreenReminder> createState() => _FullScreenReminderState();
}

class _FullScreenReminderState extends ConsumerState<FullScreenReminder>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _dismiss() {
    Navigator.of(context).pop();
  }

  void _snooze() {
    // Snooze for 5 minutes by returning a snooze result
    Navigator.of(context).pop({'action': 'snooze'});
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final color = NoteColors.fromName(note.colorName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black87 : color,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reminder',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  Row(
                    children: [
                      if (note.alarmEnabled)
                        const Icon(Icons.alarm, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatUtils.formatTime(note.reminderDateTime ?? DateTime.now()),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Note content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    note.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  if (note.description.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withAlpha(26)
                            : Colors.black.withAlpha(13),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        note.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white70 : Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (note.reminderDateTime != null)
                    Text(
                      DateFormatUtils.formatDateTime(note.reminderDateTime!),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _snooze,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: isDark ? Colors.white70 : Colors.black54,
                      ),
                      child: const Text(
                        'Snooze',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _dismiss,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor:
                            isDark ? Colors.white : Colors.black87,
                        foregroundColor:
                            isDark ? Colors.black87 : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
