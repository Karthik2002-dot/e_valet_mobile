import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

/// Action card (Park Vehicle / Retrieve Vehicle) that fits height to its content.
class DriverActionCard extends StatelessWidget {
  final String imagePath;
  final String buttonLabel;
  final VoidCallback? onTap;
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;

  const DriverActionCard({
    super.key,
    required this.imagePath,
    required this.buttonLabel,
    this.onTap,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final w = screenWidth;
    final h = screenHeight;
    final isTappable = onTap != null;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(w * 0.045),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow10,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isTappable ? onTap : null,
          borderRadius: BorderRadius.circular(w * 0.045),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.045,
              vertical: h * 0.014,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: h * 0.22),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: h * 0.018),
                  decoration: BoxDecoration(
                    color: AppColors.actionButtonYellow,
                    borderRadius: BorderRadius.circular(w * 0.025),
                  ),
                  child: Center(
                    child: TextComponent(
                      labelText: buttonLabel,
                      fontSize: isDesktop
                          ? w * 0.018
                          : isTablet
                              ? w * 0.028
                              : w * 0.048,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
