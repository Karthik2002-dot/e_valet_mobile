import 'package:flutter/material.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;

    return TextComponent(
      labelText: isReparking
          ? TextConstants.reParkingEntryReview
          : TextConstants.reviewEntry,
      fontSize: screenWidth * 0.05,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    );
  }
}
