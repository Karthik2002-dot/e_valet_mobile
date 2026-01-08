import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/slider_action_button.dart';

class HandoverButtonsSection extends StatefulWidget {
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
  State<HandoverButtonsSection> createState() => HandoverButtonsSectionState();
}

class HandoverButtonsSectionState extends State<HandoverButtonsSection> {
  Key _customerMissingKey = UniqueKey();

  void resetCustomerMissingButton() {
    setState(() {
      _customerMissingKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Confirm Handover Slide Button
        SliderActionButton(
          labelText: TextConstants.slideToConfirmHandover,
          isLoading: widget.isLoading,
          backgroundColor: AppColors.white,
          onSlideComplete: widget.onConfirmHandover,
          buttonColor: AppColors.primary,
          labelColor: AppColors.black,
          icon: Icons.handshake,
        ),

        SizedBox(height: screenHeight * 0.02),

        // Customer Missing Slide Button
        SliderActionButton(
          key: _customerMissingKey,
          labelText: TextConstants.slideToCustomerMissing,
          isLoading: false, // Customer missing doesn't need loading state
          onSlideComplete: widget.onCustomerMissing ?? () {},
          buttonColor: AppColors.error,
          backgroundColor: AppColors.white,
          labelColor: AppColors.black,
          icon: Icons.warning,
        ),
      ],
    );
  }
}
