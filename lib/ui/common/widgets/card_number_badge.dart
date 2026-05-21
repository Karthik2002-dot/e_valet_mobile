import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/typography.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

/// Card number badge per design system: off-white bg, coral border, near-black text.
class CardNumberBadge extends StatelessWidget {
  final String label;
  final String value;

  const CardNumberBadge({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.coral, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextComponent(
            labelText: label.toUpperCase(),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.nearBlack,
            letterSpacing: 0.6,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.style(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.nearBlack,
            ),
          ),
        ],
      ),
    );
  }
}
