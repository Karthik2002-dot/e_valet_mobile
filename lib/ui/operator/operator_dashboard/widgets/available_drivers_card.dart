import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/available_drivers.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/driver_card_content.dart';

class AvailableDriversCard extends StatelessWidget {
  final AvailableDriver driver;
  final bool isRecommended;

  const AvailableDriversCard({
    super.key,
    required this.driver,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
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
                    SizedBox(width: MediaQuery.of(context).size.width * 0.005),
                    Text(
                      'Recommended - Parked this vehicle',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.012,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
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
