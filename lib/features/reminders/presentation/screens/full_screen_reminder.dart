import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticky_notes/core/models/note_model.dart';
import 'package:sticky_notes/features/notes/presentation/providers/note_provider.dart';
import 'package:sticky_notes/features/settings/presentation/providers/settings_provider.dart';
import 'package:sticky_notes/shared/utils/date_utils.dart';
import 'package:sticky_notes/shared/utils/enums.dart';
import 'package:sticky_notes/core/services/alarm_service.dart';
import 'package:sticky_notes/core/services/notification_service.dart';
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
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _dismiss() async {
    final note = widget.note;
    
    // Handle repeating options
    final repeatType = note.repeatType == 'daily'
        ? RepeatType.daily
        : note.repeatType == 'weekly'
            ? RepeatType.weekly
            : note.repeatType == 'monthly'
                ? RepeatType.monthly
                : RepeatType.once;

    if (note.reminderDateTime != null) {
      final nextDate = DateFormatUtils.nextRepeatDate(note.reminderDateTime!, repeatType);
      note.reminderDateTime = nextDate;
    }

    // Save and clear current active alarm
    await ref.read(noteNotifierProvider.notifier).updateNote(note);
    await AlarmService.cancelAlarm(note);
    await NotificationService.cancelNotification(note);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _snooze() async {
    final note = widget.note;
    
    // Snooze for 10 minutes
    final newReminder = DateTime.now().add(const Duration(minutes: 10));
    note.reminderDateTime = newReminder;

    // Update, save and reschedule alarm
    await ref.read(noteNotifierProvider.notifier).updateNote(note);
    await AlarmService.scheduleAlarm(note);
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final settings = ref.watch(settingsProvider);
    final profileName = settings.profileName;
    final profileImagePath = settings.profileImagePath;

    ImageProvider? avatarImage;
    if (profileImagePath.isNotEmpty) {
      if (profileImagePath.startsWith('http') || profileImagePath.startsWith('https')) {
        avatarImage = NetworkImage(profileImagePath);
      } else {
        avatarImage = FileImage(File(profileImagePath));
      }
    } else {
      avatarImage = const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=256');
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF59E0B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.important_devices, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Full Screen Alert',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundImage: avatarImage,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'For $profileName',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Bell Icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(51),
                ),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Color(0xFFF59E0B),
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${note.category.toUpperCase()} REMINDER',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Note Title
              Text(
                note.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.3,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              // Divider line
              Container(
                width: 60,
                height: 2,
                color: Colors.white.withAlpha(128),
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                note.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  color: Colors.white.withAlpha(229),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              // Due badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'DUE IN ${DateFormatUtils.relativeTime(note.reminderDateTime ?? DateTime.now())}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              // Buttons
              OutlinedButton(
                onPressed: _snooze,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.snooze, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Snooze (10m)',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _dismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFF59E0B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, color: Color(0xFFF59E0B)),
                    SizedBox(width: 8),
                    Text(
                      'Dismiss Task',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
