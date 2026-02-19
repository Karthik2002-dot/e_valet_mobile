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
    // Use same layout as iOS on all platforms so Android has no overflow (full data visible)
    const padding = 12.0;
    Widget content = isLoading
        ? Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SkeletonLoader(
                    height: 40,
                    width: 40,
                    borderRadius: 20,
                  ),
                  const SizedBox(width: 8),
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
                  const Flexible(
                    child: SkeletonLoader(
                      height: 24,
                      width: 56,
                      borderRadius: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 24,
                        color: AppColors.grey,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextComponent(
                          labelText: valet!.name,
                          fontSize: screenWidth * 0.024,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        TextComponent(
                          labelText: valet!.phone,
                          fontSize: screenWidth * 0.018,
                          color: AppColors.grey,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ValetUtils.getStatusColor(valet!.status)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextComponent(
                        labelText: ValetUtils.getStatusLabel(valet!.status),
                        fontSize: screenWidth * 0.018,
                        color: ValetUtils.getStatusColor(valet!.status),
                        fontWeight: FontWeight.w500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              TextComponent(
                labelText:
                    '${TextConstants.carsPickedUpLabel}${valet!.carsPickedUp}',
                fontSize: screenWidth * 0.02,
                color: AppColors.black,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              TextComponent(
                labelText:
                    '${TextConstants.carsHandedOverLabel}${valet!.carsHandedOver}',
                fontSize: screenWidth * 0.02,
                color: AppColors.black,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              TextComponent(
                labelText:
                    '${TextConstants.onBreakDurationLabel}${valet!.onBreakDurationMinutes}${TextConstants.minsLabel}',
                fontSize: screenWidth * 0.02,
                color: AppColors.black,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );

    return Container(
      padding: const EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
      ),
      child: content,
    );
  }
}
