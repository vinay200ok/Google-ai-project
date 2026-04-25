import 'package:intl/intl.dart';

class DateFormatter {
  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  static String formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);

  static String formatDate(DateTime dt) =>
      DateFormat('MMM d, yyyy').format(dt);

  static String formatDateTime(DateTime dt) =>
      DateFormat('MMM d • HH:mm').format(dt);

  static String eventTime(DateTime dt) =>
      DateFormat('EEE, MMM d • h:mm a').format(dt);
}
