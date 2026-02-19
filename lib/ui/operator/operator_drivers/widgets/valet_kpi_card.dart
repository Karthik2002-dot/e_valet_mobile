import 'dart:io';

import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/skeleton_loader.dart';

class ValetKpiCard extends StatelessWidget {
  final String value;
  final String label;
  final bool isLoading;
  final bool isSelected;
  final VoidCallback? onTap;

  const ValetKpiCard({
    super.key,
    required this.value,
    required this.label,
    this.isLoading = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    final padding = isIOS ? 8.0 : 8.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(padding),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.001)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isLoading
            ? Column(
                mainAxisSize: isIOS ? MainAxisSize.max : MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonLoader(
                    height: screenHeight * (isIOS ? 0.014 : 0.015),
                    width: screenWidth * (isIOS ? 0.14 : 0.12),
                    borderRadius: 4,
                  ),
                  SizedBox(height: isIOS ? 6 : 8),
                  SkeletonLoader(
                    height: screenHeight * (isIOS ? 0.028 : 0.03),
                    width: screenWidth * (isIOS ? 0.1 : 0.08),
                    borderRadius: 4,
                  ),
                ],
              )
            : Column(
                mainAxisSize: isIOS ? MainAxisSize.max : MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextComponent(
                    labelText: label,
                    color: AppColors.black,
                    fontSize: screenWidth * (isIOS ? 0.022 : 0.02),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isIOS ? 4 : 4),
                  TextComponent(
                    labelText: value,
                    color: AppColors.black,
                    fontSize: screenWidth * (isIOS ? 0.028 : 0.025),
                    fontWeight: FontWeight.bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
      ),
    );
  }
}
