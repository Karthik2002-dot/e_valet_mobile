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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
      ),
      child: isLoading
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SkeletonLoader(
                      height: 50,
                      width: 50,
                      borderRadius: 25,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                    SkeletonLoader(
                      height: 24,
                      width: 70,
                      borderRadius: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name, phone and status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_outline,
                        size: 30,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextComponent(
                            labelText: valet!.name,
                            fontSize: screenWidth * 0.018,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          TextComponent(
                            labelText: valet!.phone,
                            fontSize: screenWidth * 0.015,
                            color: AppColors.grey,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ValetUtils.getStatusColor(valet!.status)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextComponent(
                        labelText: ValetUtils.getStatusLabel(valet!.status),
                        fontSize: screenWidth * 0.011,
                        color: ValetUtils.getStatusColor(valet!.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                // Cars Picked Up
                TextComponent(
                  labelText:
                      '${TextConstants.carsPickedUpLabel}${valet!.carsPickedUp}',
                  fontSize: screenWidth * 0.015,
                  color: AppColors.black,
                ),
                const SizedBox(height: 8),
                // Cars Handed Over
                TextComponent(
                  labelText:
                      '${TextConstants.carsHandedOverLabel}${valet!.carsHandedOver}',
                  fontSize: screenWidth * 0.015,
                  color: AppColors.black,
                ),
                const SizedBox(height: 8),
                // On-Break Duration
                TextComponent(
                  labelText:
                      '${TextConstants.onBreakDurationLabel}${valet!.onBreakDurationMinutes}${TextConstants.minsLabel}',
                  fontSize: screenWidth * 0.015,
                  color: AppColors.black,
                ),
              ],
            ),
    );
  }
}
