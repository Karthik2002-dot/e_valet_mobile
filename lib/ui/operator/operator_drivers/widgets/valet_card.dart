import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_valet/valet_response.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/skeleton_loader.dart';
import 'package:niloufer_valet_mobile/utils/time_utils.dart';
import 'package:niloufer_valet_mobile/utils/valet_utils.dart';

class ValetCard extends StatelessWidget {
  final ValetResponse? valet;
  final bool isLoading;
  final VoidCallback? onTap;

  const ValetCard({
    super.key,
    this.valet,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Slightly smaller fonts so full data fits and wraps without ellipsis
    final bodyFontSize = (screenWidth * 0.018).clamp(9.0, 12.0);
    final smallFontSize = (screenWidth * 0.016).clamp(8.0, 11.0);
    final titleFontSize = (screenWidth * 0.022).clamp(10.0, 13.0);
    const padding = 14.0;
    Widget content = isLoading
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                  const SizedBox(width: 8),
                  SkeletonLoader(
                    height: 28,
                    width: 72,
                    borderRadius: 8,
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
              const SizedBox(height: 8),
              SkeletonLoader(
                height: 14,
                width: screenWidth * 0.22,
                borderRadius: 4,
              ),
              const SizedBox(height: 8),
              SkeletonLoader(
                height: 14,
                width: screenWidth * 0.24,
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextComponent(
                            labelText: valet!.name,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                          ),
                          const SizedBox(height: 4),
                          TextComponent(
                            labelText: valet!.phone,
                            fontSize: smallFontSize,
                            color: AppColors.grey,
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status in container, top right - Flexible avoids overflow on narrow (e.g. half-width card)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ValetUtils.getStatusColor(valet!.status)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: ValetUtils.getStatusColor(valet!.status)
                                .withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: TextComponent(
                          labelText: ValetUtils.getStatusLabel(valet!.status),
                          fontSize: smallFontSize,
                          color: ValetUtils.getStatusColor(valet!.status),
                          fontWeight: FontWeight.w600,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              Row(
                children: [
                  Expanded(
                    child: TextComponent(
                      labelText:
                          '${TextConstants.carsPickedUpLabel}${valet!.carsPickedUp}',
                      fontSize: bodyFontSize,
                      color: AppColors.black,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextComponent(
                      labelText:
                          '${TextConstants.carsHandedOverLabel}${valet!.carsHandedOver}',
                      fontSize: bodyFontSize,
                      color: AppColors.black,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextComponent(
                      labelText:
                          '${TextConstants.onBreakDurationLabel}${valet!.onBreakDurationMinutes}${TextConstants.minsLabel}',
                      fontSize: bodyFontSize,
                      color: AppColors.black,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextComponent(
                      labelText:
                          '${TextConstants.clockInAtLabel}${valet!.clockInAt.isNotEmpty ? TimeUtils.formatUtcToIstFullDateTime(valet!.clockInAt) : 'N/A'}',
                      fontSize: bodyFontSize,
                      color: AppColors.black,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              if (valet!.clockOutAt.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextComponent(
                        labelText:
                            '${TextConstants.clockOutAtLabel}${TimeUtils.formatUtcToIstFullDateTime(valet!.clockOutAt)}',
                        fontSize: bodyFontSize,
                        color: AppColors.black,
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextComponent(
                      labelText:
                          '${TextConstants.lastActivityLabel}${valet!.lastActivity.isNotEmpty ? TimeUtils.formatUtcToIstFullDateTime(valet!.lastActivity) : 'N/A'}',
                      fontSize: bodyFontSize,
                      color: AppColors.black,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ],
          );

    final container = Container(
      padding: const EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
      ),
      child: content,
    );

    if (onTap != null && valet != null && !isLoading) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: container,
        ),
      );
    }
    return container;
  }
}
