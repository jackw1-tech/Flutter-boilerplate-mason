import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    final formatter = DateFormat(format);
    return formatter.format(date);
  }

  static String formatTime(DateTime time, {String format = 'HH:mm'}) {
    final formatter = DateFormat(format);
    return formatter.format(time);
  }

  static String formatDateTime(DateTime dateTime,
      {String format = 'dd/MM/yyyy HH:mm'}) {
    final formatter = DateFormat(format);
    return formatter.format(dateTime);
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} anni fa';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} mesi fa';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} giorni fa';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ore fa';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuti fa';
    } else {
      return 'adesso';
    }
  }
}
