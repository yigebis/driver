import 'package:intl/intl.dart';

String formatHumanFriendlyTime(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(Duration(days: 1));
  final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

  // If within 1 minute of now
  if (dateTime.difference(now).inSeconds < 60) {
    return 'Now';
  } else if (dateOnly == today) {
    return 'Today at ${DateFormat('h:mm a').format(dateTime)}';
  } else if (dateOnly == tomorrow) {
    return 'Tomorrow at ${DateFormat('h:mm a').format(dateTime)}';
  } else {
    return DateFormat('EEE, MMM d \'at\' h:mm a').format(dateTime);
  }
}
