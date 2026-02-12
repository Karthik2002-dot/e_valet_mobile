import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:url_launcher/url_launcher.dart';

/// Play Store link for Niloufer Valet app.
const String kPlayStoreUrl =
    'https://play.google.com/store/apps/details?id=com.niloufer.valet&pcampaignid=web_share';

/// Non-dismissible mandatory update popup (dialog).
/// - Update Now: opens Play Store.
/// - Later: does nothing (user stays on dialog).
class MandatoryUpdateDialog extends StatelessWidget {
  const MandatoryUpdateDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (ctx) => PopScope(
        canPop: false,
        child: const MandatoryUpdateDialog(),
      ),
    );
  }

  Future<void> _openPlayStore() async {
    final uri = Uri.parse(kPlayStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.system_update_rounded,
                size: 56,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 24),
            TextComponent(
              labelText: TextConstants.mandatoryUpdateDialogTitle,
              textAlign: TextAlign.center,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
            const SizedBox(height: 8),
            TextComponent(
              labelText: TextConstants.mandatoryUpdateDialogSubtitle,
              textAlign: TextAlign.center,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.mutedText,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _openPlayStore,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: TextComponent(
                  labelText: TextConstants.mandatoryUpdateDialogUpdateNow,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
