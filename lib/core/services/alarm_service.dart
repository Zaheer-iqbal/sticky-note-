import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:sticky_notes/core/models/note_model.dart';

class AlarmService {
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'alarm_channel',
          channelName: 'Alarms',
          channelDescription: 'Note alarm notifications',
          defaultColor: const Color(0xFFFFC107),
          ledColor: const Color(0xFFFFC107),
          playSound: true,
          enableVibration: true,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          locked: true,
          criticalAlerts: true,
        ),
      ],
      debug: false,
    );
  }

  static Future<void> scheduleAlarm(NoteModel note) async {
    if (note.reminderDateTime == null) return;
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: note.id.hashCode,
        channelKey: 'alarm_channel',
        title: 'Alarm: ${note.title}',
        body: note.description.isNotEmpty
            ? note.description
            : 'You have an alarm',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Alarm,
        wakeUpScreen: true,
        backgroundColor: const Color(0xFFFFC107),
      ),
      schedule: NotificationCalendar.fromDate(
        date: note.reminderDateTime!,
      ),
    );
  }

  static Future<void> cancelAlarm(NoteModel note) async {
    await AwesomeNotifications().cancel(note.id.hashCode);
  }

  static Future<void> cancelAllAlarms() async {
    await AwesomeNotifications().cancelAll();
  }
}
