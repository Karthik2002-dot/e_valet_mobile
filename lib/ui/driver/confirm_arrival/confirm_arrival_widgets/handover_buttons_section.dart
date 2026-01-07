import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/confirm_arrival_widgets/slide_action_button.dart';

class HandoverButtonsSection extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onConfirmHandover;
  final VoidCallback? onCustomerMissing;

  const HandoverButtonsSection({
    super.key,
    required this.isLoading,
    required this.onConfirmHandover,
    this.onCustomerMissing,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Confirm Handover Slide Button
        SlideActionButton(
          text: TextConstants.slideToConfirmHandover,
          isLoading: isLoading,
          onConfirm: onConfirmHandover,
          buttonColor: AppColors.primary,
          textColor: AppColors.black,
          icon: Icons.arrow_forward,
        ),

        SizedBox(height: screenHeight * 0.02),

        // Customer Missing Slide Button
        SlideActionButton(
          text: TextConstants.slideToCustomerMissing,
          isLoading: false, // Customer missing doesn't need loading state
          onConfirm: onCustomerMissing ?? () {},
          buttonColor: AppColors.error,
          textColor: AppColors.error,
          icon: Icons.arrow_forward,
        ),
      ],
    );
  }
}
