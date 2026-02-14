import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class HandoverButtonsSection extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onConfirmHandover;
  final Future<void> Function()? onCustomerMissing;

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
  bool _isCustomerMissingLoading = false;

  void resetCustomerMissingButton() {
    setState(() {
      _customerMissingKey = UniqueKey();
    });
  }

  Widget _buildActionButton({
    Key? key,
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required bool isLoading,
    required VoidCallback? onPressed,
    required bool bigStyle,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: backgroundColor.withOpacity(0.7),
        disabledForegroundColor: foregroundColor.withOpacity(0.7),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: bigStyle ? screenWidth * 0.08 : screenHeight * 0.03,
                  color: foregroundColor,
                ),
                SizedBox(width: bigStyle ? 16 : 10),
                TextComponent(
                  labelText: label,
                  fontSize:
                      bigStyle ? screenWidth * 0.06 : screenHeight * 0.025,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
              ],
            ),
    );

    if (bigStyle) {
      return Expanded(
        child: SizedBox(key: key, width: double.infinity, child: button),
      );
    }
    return SizedBox(
      key: key,
      width: double.infinity,
      height: screenHeight * 0.07,
      child: button,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextComponent(
          labelText: TextConstants.pressBelowToConfirmHandover,
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenHeight * 0.012),
        _buildActionButton(
          label: TextConstants.slideToConfirmHandover,
          icon: Icons.handshake,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.black,
          isLoading: widget.isLoading,
          onPressed: widget.onConfirmHandover,
          bigStyle: true,
        ),
        SizedBox(height: screenHeight * 0.02),
        TextComponent(
          labelText: TextConstants.pressBelowToReportCustomerMissing,
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenHeight * 0.012),
        _buildActionButton(
          key: _customerMissingKey,
          label: TextConstants.slideToCustomerMissing,
          icon: Icons.warning,
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.white,
          isLoading: _isCustomerMissingLoading,
          onPressed: () async {
            if (_isCustomerMissingLoading) return;
            final onCustomerMissing = widget.onCustomerMissing;
            if (onCustomerMissing == null) return;
            setState(() => _isCustomerMissingLoading = true);
            try {
              await onCustomerMissing();
            } finally {
              if (mounted) {
                setState(() => _isCustomerMissingLoading = false);
              }
            }
          },
          bigStyle: true,
        ),
      ],
    );
  }
}
