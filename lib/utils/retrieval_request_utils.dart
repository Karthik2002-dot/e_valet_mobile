import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/utils/time_utils.dart';

class RetrievalRequestUtils {
  RetrievalRequestUtils._();

  static Color getPriorityColor(String waitingTime) {
    final minutesStr = waitingTime.replaceAll(RegExp(r'[^0-9]'), '');
    final minutes = int.tryParse(minutesStr) ?? 0;

    if (minutes >= 30) {
      return AppColors.error;
    } else if (minutes >= 15) {
      return AppColors.primary;
    }
    return AppColors.success;
  }

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

  static String formatTime(String dateTimeStr) {
    return TimeUtils.formatUtcToIst12Hour(dateTimeStr);
  }

  /// Whether this retrieval request is assignable based on its status
  static bool isAssignable(String status) {
    final normalized = status.toUpperCase();
    return normalized == 'RETRIEVAL_REQUESTED';
  }

  /// Status-based color for the request card / status pill
  static Color getStatusColor({
    required String status,
    required String waitingTime,
  }) {
    switch (status.toUpperCase()) {
      case 'ASSIGNED':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.blue;
      case 'ARRIVED':
        return Colors.green;
      case 'RETRIEVAL_REQUESTED':
      default:
        return getPriorityColor(waitingTime);
    }
  }

  /// Status label to show in UI
  static String getStatusLabel({
    required String status,
    required String waitingTime,
  }) {
    switch (status.toUpperCase()) {
      case 'ASSIGNED':
        return 'Assigned';
      case 'ACCEPTED':
        return 'Accepted';
      case 'ARRIVED':
        return 'Arrived';
      case 'RETRIEVAL_REQUESTED':
      default:
        return getPriorityLabel(waitingTime);
    }
  }
}
