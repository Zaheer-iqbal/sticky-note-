import 'package:intl/intl.dart';
import 'enums.dart';

class DateFormatUtils {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = dateTime.difference(now);

    if (diff.isNegative) {
      return 'Overdue';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d remaining';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h remaining';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m remaining';
    } else {
      return 'Due now';
    }
  }

  static DateTime? nextRepeatDate(DateTime original, RepeatType repeat) {
    final now = DateTime.now();
    switch (repeat) {
      case RepeatType.daily:
        return DateTime(now.year, now.month, now.day, original.hour, original.minute)
            .add(const Duration(days: 1));
      case RepeatType.weekly:
        return original.add(const Duration(days: 7));
      case RepeatType.monthly:
        return DateTime(now.year, now.month + 1, original.day, original.hour, original.minute);
      case RepeatType.once:
        return null;
    }
  }
}
