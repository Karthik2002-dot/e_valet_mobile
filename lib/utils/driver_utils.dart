import 'package:flutter/material.dart';

class DriverUtils {
  DriverUtils._();

  /// Generate initials from a full name
  /// Example: "Karthik AH" -> "KA", "Manjunath H" -> "MH"
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';

    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    // Get first letter of first name and first letter of last name
    final firstInitial = parts.first.substring(0, 1).toUpperCase();
    final lastInitial = parts.last.substring(0, 1).toUpperCase();

    return '$firstInitial$lastInitial';
  }

  /// Get color based on driver status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'free':
      case 'available':
        return Colors.green;
      case 'busy':
      case 'occupied':
        return Colors.orange;
      case 'offline':
      case 'unavailable':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
