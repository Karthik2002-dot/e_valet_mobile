import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

part 'slide_action_button_state.dart';

class SlideActionButton extends StatefulWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onConfirm;
  final Color? buttonColor;
  final Color? textColor;
  final IconData? icon;

  const SlideActionButton({
    super.key,
    required this.text,
    required this.isLoading,
    required this.onConfirm,
    this.buttonColor,
    this.textColor,
    this.icon,
  });

  @override
  State<SlideActionButton> createState() => _SlideActionButtonState();
}
