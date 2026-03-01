import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class PreviewHeader extends StatelessWidget {
  final bool isReparking;

  const PreviewHeader({
    super.key,
    this.isReparking = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTranslationsNotifier>();
    final screenWidth = MediaQuery.of(context).size.width;

    return TextComponent(
      labelText: isReparking
          ? t.get(TextConstants.reParkingEntryReview)
          : t.get(TextConstants.reviewEntry),
      fontSize: screenWidth * 0.05,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    );
  }
}
