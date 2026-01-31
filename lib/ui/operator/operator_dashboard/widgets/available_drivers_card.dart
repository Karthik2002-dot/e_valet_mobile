import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/available_drivers.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/driver_card_content.dart';
import 'package:niloufer_valet_mobile/utils/driver_utils.dart';

class AvailableDriversCard extends StatelessWidget {
  final AvailableDriver driver;
  final bool isRecommended;
  final int? recommendedCardNumber;
  /// When true, shows only name and phone (max 1 line each) and card width fits content.
  final bool compact;

  const AvailableDriversCard({
    super.key,
    required this.driver,
    this.isRecommended = false,
    this.recommendedCardNumber,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return LongPressDraggable<AvailableDriver>(
        data: driver,
        delay: const Duration(milliseconds: 300),
        hapticFeedbackOnStart: true,
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Opacity(
            opacity: 0.8,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.02,
                vertical: MediaQuery.of(context).size.height * 0.008,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _CompactDriverContent(driver: driver),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02,
              vertical: MediaQuery.of(context).size.height * 0.008,
            ),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _CompactDriverContent(driver: driver),
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02,
            vertical: MediaQuery.of(context).size.height * 0.008,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: isRecommended
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: isRecommended
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.grey.withOpacity(0.1),
                spreadRadius: isRecommended ? 2 : 1,
                blurRadius: isRecommended ? 6 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isRecommended)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.004,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.recommend,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.005),
                      TextComponent(
                        labelText: recommendedCardNumber != null
                            ? '${TextConstants.recommendedFor} $recommendedCardNumber ${TextConstants.cardNumberLabel}'
                            : TextConstants.recommendedBy,
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              _CompactDriverContent(driver: driver),
            ],
          ),
        ),
      );
    }

    return LongPressDraggable<AvailableDriver>(
      data: driver,
      delay: const Duration(milliseconds: 300),
      hapticFeedbackOnStart: true,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: 0.8,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.3,
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.01,
              vertical: MediaQuery.of(context).size.height * 0.01,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DriverCardContent(driver: driver),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.015,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.01,
            vertical: MediaQuery.of(context).size.height * 0.01,
          ),
          decoration: BoxDecoration(
            color: AppColors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DriverCardContent(driver: driver),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.015,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.01,
          vertical: MediaQuery.of(context).size.height * 0.01,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: isRecommended
              ? Border.all(
                  color: AppColors.primary,
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: isRecommended
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.grey.withOpacity(0.1),
              spreadRadius: isRecommended ? 2 : 1,
              blurRadius: isRecommended ? 6 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            if (isRecommended)
              Container(
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.008,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.01,
                  vertical: MediaQuery.of(context).size.height * 0.004,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.recommend,
                      size: MediaQuery.of(context).size.width * 0.014,
                      color: AppColors.primary,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.005,
                    ),
                    TextComponent(
                      labelText: recommendedCardNumber != null
                          ? '${TextConstants.recommendedFor} $recommendedCardNumber ${TextConstants.cardNumberLabel}'
                          : TextConstants.recommendedBy,
                      fontSize: MediaQuery.of(context).size.width * 0.012,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            DriverCardContent(driver: driver),
          ],
        ),
      ),
    );
  }
}

/// Compact content: name and phone only, each max 1 line. Card width fits content.
class _CompactDriverContent extends StatelessWidget {
  final AvailableDriver driver;

  const _CompactDriverContent({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: TextComponent(
            labelText: DriverUtils.getInitials(driver.name),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.015),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextComponent(
              labelText: driver.name,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.002),
            TextComponent(
              labelText: driver.phone,
              fontSize: 12,
              color: AppColors.grey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }
}
