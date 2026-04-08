import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Date/time formatting utilities
class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateShort = DateFormat('MMM d, yyyy');
  static final DateFormat _dateLong = DateFormat('MMMM d, yyyy');
  static final DateFormat _time = DateFormat('h:mm a');
  static final DateFormat _dateTime = DateFormat('MMM d, yyyy • h:mm a');
  static final DateFormat _dateTimeShort = DateFormat('MMM d • h:mm a');
  static final DateFormat _dayMonth = DateFormat('MMM d');
  static final DateFormat _weekday = DateFormat('EEEE');
  static final DateFormat _iso = DateFormat('yyyy-MM-dd');

  /// "Apr 6, 2026"
  static String dateShort(DateTime date) => _dateShort.format(date.toLocal());

  /// "April 6, 2026"
  static String dateLong(DateTime date) => _dateLong.format(date.toLocal());

  /// "2:30 PM"
  static String time(DateTime date) => _time.format(date.toLocal());

  /// "Apr 6, 2026 • 2:30 PM"
  static String dateTime(DateTime date) => _dateTime.format(date.toLocal());

  /// "Apr 6 • 2:30 PM"
  static String dateTimeShort(DateTime date) => _dateTimeShort.format(date.toLocal());

  /// "Apr 6"
  static String dayMonth(DateTime date) => _dayMonth.format(date.toLocal());

  /// "Monday"
  static String weekday(DateTime date) => _weekday.format(date.toLocal());

  /// "2026-04-06"
  static String iso(DateTime date) => _iso.format(date.toLocal());

  /// "2 hours ago", "in 3 days"
  static String relative(DateTime date) => timeago.format(date);

  /// "Due in 2 days" or "Overdue by 3 days"
  static String dueStatus(DateTime? dueDate) {
    if (dueDate == null) return 'No due date';
    final now = DateTime.now();
    final diff = dueDate.difference(now);

    if (diff.isNegative) {
      final days = diff.inDays.abs();
      if (days == 0) return 'Due today';
      if (days == 1) return 'Overdue by 1 day';
      return 'Overdue by $days days';
    } else {
      final days = diff.inDays;
      if (days == 0) return 'Due today';
      if (days == 1) return 'Due tomorrow';
      return 'Due in $days days';
    }
  }

  /// Whether the date is overdue (past now)
  static bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return dueDate.isBefore(DateTime.now());
  }

  /// Whether the date is due soon (within 24 hours)
  static bool isDueSoon(DateTime? dueDate) {
    if (dueDate == null) return false;
    final diff = dueDate.difference(DateTime.now());
    return diff.inHours >= 0 && diff.inHours <= 24;
  }
}
