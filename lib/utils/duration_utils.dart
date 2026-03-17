class DurationUtils {
  DurationUtils._();

  /// Splits a total minutes value into (hours, minutes) with minutes in 0..59.
  /// Negative values are clamped to 0.
  static ({int hours, int minutes}) splitToHoursMinutes(int totalMinutes) {
    final clamped = totalMinutes < 0 ? 0 : totalMinutes;
    return (hours: clamped ~/ 60, minutes: clamped % 60);
  }
}
