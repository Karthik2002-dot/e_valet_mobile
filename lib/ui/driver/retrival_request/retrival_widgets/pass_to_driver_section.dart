import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';

class PassToDriverSection extends StatelessWidget {
  final double screenWidth;
  final bool isPassing;
  final VoidCallback? onPass;

  const PassToDriverSection({
    super.key,
    required this.screenWidth,
    required this.isPassing,
    required this.onPass,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(color: AppColors.divider, height: 24),

        // Section header
        Row(
          children: [
            const Icon(Icons.swap_horiz_rounded,
                size: 18, color: AppColors.mutedText),
            const SizedBox(width: 6),
            Text(
              'Pass to Another Driver',
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 55,
          child: ElevatedButton.icon(
            onPressed: isPassing ? null : onPass,
            icon: isPassing
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.black),
                    ),
                  )
                : const Icon(
                    Icons.swap_horiz_rounded,
                    size: 18,
                    color: AppColors.black,
                  ),
            label: Text(
              isPassing ? 'Passing...' : 'Pass',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF87171),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
