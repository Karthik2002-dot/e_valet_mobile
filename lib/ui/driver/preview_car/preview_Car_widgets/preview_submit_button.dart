import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/typography.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class PreviewSubmitButton extends StatelessWidget {
  final VoidCallback onSubmit;
  final bool isReparking;
  final bool isLoading;
  final bool isEnabled;
  final String? overrideLabel;

  const PreviewSubmitButton({
    super.key,
    required this.onSubmit,
    this.isReparking = false,
    this.isLoading = false,
    this.isEnabled = true,
    this.overrideLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTranslationsNotifier>();
    final screenWidth = MediaQuery.of(context).size.width;
    final canPress = isEnabled && !isLoading;

    final bgColor = isReparking ? AppColors.nearBlack : AppColors.coral;

    return Semantics(
      button: true,
      enabled: canPress,
      label: overrideLabel ??
          (isReparking
              ? t.get(TextConstants.submitRePark)
              : t.getByKey('submitButton', TextConstants.submitButton)),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: canPress ? onSubmit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.disabledBackground,
            disabledForegroundColor: AppColors.disabledText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextComponent(
                      labelText: overrideLabel ??
                          (isReparking
                              ? t.get(TextConstants.submitRePark)
                              : t.getByKey(
                                  'submitButton', TextConstants.submitButton)),
                      fontSize: AppTypography.cta,
                      fontWeight: FontWeight.bold,
                      color: canPress ? AppColors.white : AppColors.disabledText,
                    ),
                    if (overrideLabel == null && !isReparking) ...[
                      SizedBox(width: screenWidth * 0.02),
                      Icon(
                        Icons.arrow_forward,
                        color: canPress ? AppColors.white : AppColors.disabledText,
                        size: AppTypography.cta,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
