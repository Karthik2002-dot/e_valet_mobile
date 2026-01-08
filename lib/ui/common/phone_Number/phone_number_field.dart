import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/phone_Number/phone_number_field_state.dart';

class PhoneNumberField extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final String initialCountryCode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final bool disableCountryPicker;

  const PhoneNumberField({
    super.key,
    required this.labelText,
    this.hintText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.initialCountryCode = 'IN',
    this.textInputAction,
    this.onSubmitted,
    this.disableCountryPicker = false,
  });

  @override
  State<PhoneNumberField> createState() => PhoneNumberFieldState();
}
