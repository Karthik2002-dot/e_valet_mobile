import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

/// Overtime confirmation dialog: "You have extended the [name] time [X] minutes more extra."
/// Shows Cancel and Confirm; on Confirm calls [onConfirm].
/// Backend key [overtimeConfirmMessage] expects template with {valetName} and {minutes}.
class OvertimeConfirmDialog {
  OvertimeConfirmDialog._();

  static String _formatOvertimeConfirmMessage(
    AppTranslationsNotifier t,
    String valetName,
    int extraMinutes,
  ) {
    final template = t.getByKey(
      'overtimeConfirmMessage',
      TextConstants.overtimeConfirmMessage(valetName, extraMinutes),
    );
    return template
        .replaceAll('{valetName}', valetName)
        .replaceAll('{minutes}', extraMinutes.toString());
  }

  static void show(
    BuildContext context, {
    required String driverUserId,
    required int extraMinutes,
    required String valetName,
    required VoidCallback onConfirm,
  }) {
    final t = context.read<AppTranslationsNotifier>();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: TextComponent(
          labelText: t.getByKey(
              'overtimeConfirmTitle', TextConstants.overtimeConfirmTitle),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        content: TextComponent(
          labelText: _formatOvertimeConfirmMessage(
            t,
            valetName,
            extraMinutes,
          ),
          fontSize: 16,
          color: AppColors.black,
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.grey,
              side: BorderSide(color: AppColors.grey.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: TextComponent(
              labelText: t.get(TextConstants.cancelText),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: TextComponent(
              labelText: t.get(TextConstants.confirm),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
