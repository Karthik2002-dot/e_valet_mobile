import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class ValetUtils {
  ValetUtils._();

  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return AppColors.success;
      case 'ON_DUTY':
        return AppColors.orange;
      case 'ON_BREAK':
        return AppColors.error;
      case 'OFFLINE':
        return AppColors.grey;
      default:
        return AppColors.grey;
    }
  }

  /// Returns display label for API status (Available, On Duty, On Break, Offline).
  static String getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return TextConstants.statusAvailable;
      case 'ON_DUTY':
        return TextConstants.statusOnDuty;
      case 'ON_BREAK':
        return TextConstants.statusOnBreak;
      case 'OFFLINE':
        return TextConstants.statusOffline;
      default:
        return status.isNotEmpty ? status : 'Offline';
    }
  }

  /// Online if status is not OFFLINE (e.g. AVAILABLE, ON_DUTY, ON_BREAK).
  static bool isOnline(String status) {
    return status.toUpperCase() != 'OFFLINE';
  }
}
