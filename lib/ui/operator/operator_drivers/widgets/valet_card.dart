import 'dart:io';

import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_valet/valet_response.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/skeleton_loader.dart';
import 'package:niloufer_valet_mobile/utils/valet_utils.dart';

class ValetCard extends StatelessWidget {
  final ValetResponse? valet;
  final bool isLoading;

  const ValetCard({
    super.key,
    this.valet,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isIOS = Platform.isIOS;
    final padding = isIOS ? 12.0 : 16.0;

    final fillSpace = isIOS;
    Widget content = isLoading
        ? Column(
            mainAxisSize: fillSpace ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: fillSpace ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SkeletonLoader(
                    height: isIOS ? 40 : 50,
                    width: isIOS ? 40 : 50,
                    borderRadius: isIOS ? 20 : 25,
                  ),
                  SizedBox(width: isIOS ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SkeletonLoader(
                          height: 16,
                          width: screenWidth * 0.15,
                          borderRadius: 4,
                        ),
                        const SizedBox(height: 8),
                        SkeletonLoader(
                          height: 14,
                          width: screenWidth * 0.12,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SkeletonLoader(
                      height: 24,
                      width: isIOS ? 56 : 70,
                      borderRadius: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isIOS ? 12 : 16),
              SkeletonLoader(
                height: 14,
                width: screenWidth * 0.18,
                borderRadius: 4,
              ),
              const SizedBox(height: 8),
              SkeletonLoader(
                height: 14,
                width: screenWidth * 0.16,
                borderRadius: 4,
              ),
              const SizedBox(height: 8),
              SkeletonLoader(
                height: 14,
                width: screenWidth * 0.2,
                borderRadius: 4,
              ),
            ],
          )
        : Column(
            mainAxisSize: fillSpace ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: fillSpace ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: isIOS ? 40 : 50,
                      height: isIOS ? 40 : 50,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: isIOS ? 24 : 30,
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(width: isIOS ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextComponent(
                          labelText: valet!.name,
                          fontSize: screenWidth * (isIOS ? 0.024 : 0.025),
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        TextComponent(
                          labelText: valet!.phone,
                          fontSize: screenWidth * (isIOS ? 0.018 : 0.02),
                          color: AppColors.grey,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isIOS ? 8 : 12,
                        vertical: isIOS ? 4 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: ValetUtils.getStatusColor(valet!.status)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextComponent(
                        labelText: ValetUtils.getStatusLabel(valet!.status),
                        fontSize: screenWidth * (isIOS ? 0.018 : 0.02),
                        color: ValetUtils.getStatusColor(valet!.status),
                        fontWeight: FontWeight.w500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              if (!fillSpace) SizedBox(height: isIOS ? 12 : 16),
              TextComponent(
                labelText:
                    '${TextConstants.carsPickedUpLabel}${valet!.carsPickedUp}',
                fontSize: screenWidth * (isIOS ? 0.02 : 0.02),
                color: AppColors.black,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              TextComponent(
                labelText:
                    '${TextConstants.carsHandedOverLabel}${valet!.carsHandedOver}',
                fontSize: screenWidth * (isIOS ? 0.02 : 0.02),
                color: AppColors.black,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              TextComponent(
                labelText:
                    '${TextConstants.onBreakDurationLabel}${valet!.onBreakDurationMinutes}${TextConstants.minsLabel}',
                fontSize: screenWidth * (isIOS ? 0.02 : 0.02),
                color: AppColors.black,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
      ),
      child: content,
    );
  }
}
