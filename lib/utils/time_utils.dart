class TimeUtils {
  TimeUtils._();

  /// Convert UTC DateTime to IST (Indian Standard Time - UTC+5:30)
  static DateTime utcToIst(DateTime utcDateTime) {
    return utcDateTime.add(const Duration(hours: 5, minutes: 30));
  }

  /// Parse UTC string and convert to IST DateTime
  static DateTime parseUtcToIst(String utcDateTimeStr) {
    final utcDateTime = DateTime.parse(utcDateTimeStr).toUtc();
    return utcToIst(utcDateTime);
  }

  /// Format DateTime to 12-hour format (e.g., "4:30 PM")
  static String formatTo12Hour(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Format UTC string to IST 12-hour format
  static String formatUtcToIst12Hour(String utcDateTimeStr) {
    try {
      final istDateTime = parseUtcToIst(utcDateTimeStr);
      return formatTo12Hour(istDateTime);
    } catch (e) {
      return utcDateTimeStr;
    }
  }
}
