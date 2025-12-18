import 'package:flutter/services.dart';

/// Custom input formatter for Indian phone numbers
/// Prevents users from entering 0, 1, 2, 3, 4, or 5 as the first digit
/// Only allows 6, 7, 8, or 9 as the first digit
class IndianPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the text is empty, allow it
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Check if the first digit is 0, 1, 2, 3, 4, or 5
    final firstDigit = newValue.text[0];
    if (firstDigit == '1' ||
        firstDigit == '2' ||
        firstDigit == '3' ||
        firstDigit == '4' ||
        firstDigit == '5' ||
        firstDigit == '0') {
      // Reject the input and keep the old value
      return oldValue;
    }

    // Allow the input if first digit is 6, 7, 8, or 9
    return newValue;
  }
}

/// Validates Indian phone number format
/// Returns error message if invalid, null if valid
String? validateIndianPhoneNumber(String value) {
  if (value.isEmpty) {
    return null; // Don't show error for empty field
  }

  if (value.length < 10) {
    return 'Phone number must be exactly 10 digits';
  }

  if (value.length > 10) {
    return 'Phone number must be exactly 10 digits';
  }

  // Check if first digit is 6, 7, 8, or 9
  final firstDigit = value[0];
  if (firstDigit != '6' &&
      firstDigit != '7' &&
      firstDigit != '8' &&
      firstDigit != '9') {
    return 'Phone number must start with 6, 7, 8, or 9';
  }

  return null; // Valid
}
