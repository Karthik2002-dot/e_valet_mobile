import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

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
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  late FocusNode _internalFocusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    } else {
      _internalFocusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _internalFocusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveFocusNode = widget.focusNode ?? _internalFocusNode;
    final inputDecoration = InputDecoration(
      hintText: widget.hintText,
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
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextComponent(
          labelText: widget.labelText,
          fontSize: 14,
          color: AppColors.black,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(height: 8),
        if (widget.disableCountryPicker)
          // Use regular TextField with +91 prefix when country picker is disabled
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isFocused ? AppColors.primary : AppColors.surfaceBorder,
                width: _isFocused ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Text(
                    '+91',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: effectiveFocusNode,
                    textInputAction: widget.textInputAction,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onSubmitted: widget.onSubmitted,
                    onChanged: (value) {
                      if (widget.onChanged != null) {
                        // Always prepend +91 since country picker is disabled
                        widget.onChanged!('+91$value');
                      }
                    },
                    decoration: inputDecoration.copyWith(
                      hintText: widget.hintText,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          IntlPhoneField(
            initialCountryCode: widget.initialCountryCode,
            controller: widget.controller,
            focusNode: widget.focusNode,
            textInputAction: widget.textInputAction,
            decoration: inputDecoration,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.black,
            ),
            onSubmitted: widget.onSubmitted,
            onChanged: (PhoneNumber phone) {
              if (widget.onChanged != null) {
                widget.onChanged!(phone.completeNumber);
              }
            },
          ),
      ],
    );
  }
}
