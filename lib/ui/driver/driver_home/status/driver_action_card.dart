import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

/// Action card (Park Vehicle / Retrieve Vehicle) that fits height to its content.
class DriverActionCard extends StatelessWidget {
  final String imagePath;
  final String buttonLabel;
  final int notificationCount;
  final VoidCallback? onTap;
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;

  const DriverActionCard({
    super.key,
    required this.imagePath,
    required this.buttonLabel,
    this.notificationCount = 0,
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
        color: AppColors.transparent,
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Center(
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
                      if (notificationCount > 0)
                        Positioned(
                          right: w * 0.02,
                          top: -h * 0.008,
                          child: Container(
                            constraints: BoxConstraints(
                              minWidth: w * 0.06,
                              minHeight: h * 0.03,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: w * 0.015,
                              vertical: h * 0.003,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: TextComponent(
                                labelText: notificationCount > 99
                                    ? '99+'
                                    : notificationCount.toString(),
                                fontSize: isDesktop
                                    ? w * 0.010
                                    : isTablet
                                        ? w * 0.016
                                        : w * 0.028,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
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
