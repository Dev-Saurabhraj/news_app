import 'package:intl/intl.dart';

extension UnixTimeX on int {
  DateTime get fromUnixSeconds =>
      DateTime.fromMillisecondsSinceEpoch(this * 1000);
}

extension DateTimeX on DateTime {
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(this);
  }
}
