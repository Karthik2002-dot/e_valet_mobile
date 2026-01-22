import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class SessionIncompleteDialog extends StatelessWidget {
  final VoidCallback onContinue;

  const SessionIncompleteDialog({
    super.key,
    required this.onContinue,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onContinue,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionIncompleteDialog(
        onContinue: onContinue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false, // Prevent back button from dismissing dialog
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.06),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: screenWidth * 0.12,
                  color: AppColors.primary,
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Message Text
              TextComponent(
                labelText:
                    'Your session has been not completed please click on continue to proceed',
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: screenHeight * 0.03),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.055,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Wait for dialog to fully close before proceeding
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      onContinue();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: TextComponent(
                    labelText: 'Continue',
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
