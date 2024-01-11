import 'package:intl/intl.dart';

String timeAgoFromDateString(String dateString) {
  DateTime date = DateTime.parse(dateString);
  DateTime now = DateTime.now();
  Duration difference = now.difference(date);

  if (difference.inDays > 365) {
    int years = (difference.inDays / 365).floor();
    return years == 1 ? '$years year ago' : '$years years ago';
  } else if (difference.inDays > 30) {
    int months = (difference.inDays / 30).floor();
    return months == 1 ? '$months month ago' : '$months months ago';
  } else if (difference.inDays > 7) {
    int weeks = (difference.inDays / 7).floor();
    return weeks == 1 ? '$weeks week ago' : '$weeks weeks ago';
  } else if (difference.inDays > 0) {
    return difference.inDays == 1 ? 'Yesterday' : '${difference.inDays} days ago';
  } else if (difference.inHours > 0) {
    // Check if the difference is less than a day
    if (difference.inDays < 1) {
      // Format the date to "hh:mm a"
      return DateFormat('hh:mm a').format(date);
    } else {
      return difference.inHours == 1 ? 'An hour ago' : '${difference.inHours} hours ago';
    }
  } else if (difference.inMinutes > 0) {
    return difference.inMinutes == 1 ? 'A minute ago' : '${difference.inMinutes} minutes ago';
  } else {
    return 'Just now';
  }
}