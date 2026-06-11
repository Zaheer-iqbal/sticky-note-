import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sticky_notes/core/models/note_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Navigation handled via route listener
  }

  static Future<void> showReminderNotification(NoteModel note) async {
    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Note reminder notifications',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(
      note.id.hashCode,
      'Reminder: ${note.title}',
      note.description.isNotEmpty ? note.description : 'You have a reminder',
      details,
    );
  }

  static Future<void> cancelNotification(NoteModel note) async {
    await _plugin.cancel(note.id.hashCode);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
