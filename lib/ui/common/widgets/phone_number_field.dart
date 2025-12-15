import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:niloufer_valet_mobile/ui/common/color.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class PhoneNumberField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final String initialCountryCode;

  const PhoneNumberField({
    super.key,
    required this.labelText,
    this.hintText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.initialCountryCode = 'IN',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextComponent(
          labelText: labelText,
          fontSize: 14,
          color: AppColors.black,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(height: 8),
        IntlPhoneField(
          initialCountryCode: initialCountryCode,
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14,
              color: AppColors.grey.withOpacity(0.6),
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.surfaceBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.surfaceBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.surfaceBorder.withOpacity(0.5),
                width: 1,
              ),
            ),
            // Hide maxLength counter like "0/10"
            counterText: '',
          ),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.black,
          ),
          onChanged: (PhoneNumber phone) {
            if (onChanged != null) {
              onChanged!(phone.completeNumber);
            }
          },
        ),
      ],
    );
  }
}
