import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/utils/time_utils.dart';

class RetrievalRequestUtils {
  RetrievalRequestUtils._();

  /// Get priority color based on waiting time
  /// Red: >= 30 minutes, Orange: >= 15 minutes, Green: < 15 minutes
  static Color getPriorityColor(String waitingTime) {
    // Extract minutes from waiting time string like "93mins"
    final minutesStr = waitingTime.replaceAll(RegExp(r'[^0-9]'), '');
    final minutes = int.tryParse(minutesStr) ?? 0;

    if (minutes >= 30) {
      return Colors.red;
    } else if (minutes >= 15) {
      return Colors.orange;
    }
    return Colors.green;
  }

  /// Get priority label based on waiting time
  /// High: >= 30 minutes, Medium: >= 15 minutes, Low: < 15 minutes
  static String getPriorityLabel(String waitingTime) {
    final minutesStr = waitingTime.replaceAll(RegExp(r'[^0-9]'), '');
    final minutes = int.tryParse(minutesStr) ?? 0;

    if (minutes >= 30) {
      return 'High';
    } else if (minutes >= 15) {
      return 'Medium';
    }
    return 'Low';
  }

  /// Format UTC DateTime string to IST 12-hour format (e.g., "4:30 PM")
  static String formatTime(String dateTimeStr) {
    return TimeUtils.formatUtcToIst12Hour(dateTimeStr);
  }
}
