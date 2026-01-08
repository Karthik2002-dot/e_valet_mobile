import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/slider_action_button.dart';

class SlideToConfirmButton extends StatelessWidget {
  final String sessionId;
  final bool isLoading;
  final VoidCallback onConfirm;

  const SlideToConfirmButton({
    super.key,
    required this.sessionId,
    required this.isLoading,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SliderActionButton(
      labelText: TextConstants.slideToConfirmArrival,
      isLoading: isLoading,
      backgroundColor: AppColors.white,
      onSlideComplete: onConfirm,
      buttonColor: AppColors.primary,
      labelColor: AppColors.black,
      icon: Icons.my_location,
    );
  }
}
