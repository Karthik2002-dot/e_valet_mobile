import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/key_rack_item.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/utils/time_utils.dart';

class ParkedCarCard extends StatelessWidget {
  final KeyRackItem item;
  final VoidCallback? onTap;
  final Function(int cardNumber, String sessionId)? onManualRequest;
  final bool isHighlighted;

  const ParkedCarCard({
    super.key,
    required this.item,
    this.onTap,
    this.onManualRequest,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isHighlighted
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted
                ? AppColors.primary
                : AppColors.grey.withOpacity(0.2),
            width: isHighlighted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isHighlighted
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.black.withOpacity(0.08),
              spreadRadius: isHighlighted ? 2 : 0,
              blurRadius: isHighlighted ? 16 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Image (no overlay badge)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: item.photoUrl.isNotEmpty
                  ? Image.network(
                      item.photoUrl,
                      height: screenHeight * 0.15,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage(
                            screenWidth, screenHeight);
                      },
                    )
                  : _buildPlaceholderImage(screenWidth, screenHeight),
            ),
            // Card Info Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.01),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Number
                        Row(
                          children: [
                            Icon(
                              Icons.credit_card,
                              size: screenWidth * 0.012,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: screenWidth * 0.004),
                            TextComponent(
                              labelText: 'Card #${item.cardNumber}',
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.013,
                              color: AppColors.black,
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.008),
                        // Parking Location (if available)
                        if (item.parkingLocation != null &&
                            item.parkingLocation!.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: screenWidth * 0.011,
                                color: AppColors.error,
                              ),
                              SizedBox(width: screenWidth * 0.004),
                              Expanded(
                                child: TextComponent(
                                  labelText: item.parkingLocation!,
                                  fontSize: screenWidth * 0.01,
                                  color: AppColors.grey,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.008),
                        ],
                        // Parked By (if available)
                        if (item.parkedByName != null &&
                            item.parkedByName!.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: screenWidth * 0.011,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: screenWidth * 0.004),
                              Expanded(
                                child: TextComponent(
                                  labelText: 'Parked by ${item.parkedByName}',
                                  fontSize: screenWidth * 0.009,
                                  color: AppColors.grey,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.006),
                        ],
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Duration badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.008,
                            vertical: screenHeight * 0.003,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.15),
                                AppColors.primary.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: screenWidth * 0.01,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: screenWidth * 0.003),
                              TextComponent(
                                labelText: item.duration,
                                fontSize: screenWidth * 0.009,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.006),
                        // Parked time info (converted to IST)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: screenWidth * 0.011,
                              color: AppColors.grey,
                            ),
                            SizedBox(width: screenWidth * 0.004),
                            Expanded(
                              child: TextComponent(
                                labelText: TimeUtils.formatUtcToIstFullDateTime(
                                    item.parkedAt),
                                fontSize: screenWidth * 0.008,
                                color: AppColors.grey,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        // Manual Request Button
                        if (onManualRequest != null) ...[
                          SizedBox(height: screenHeight * 0.008),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => onManualRequest!(
                                item.cardNumber,
                                item.sessionId,
                              ),
                              label: TextComponent(
                                labelText: 'Manual Request',
                                fontSize: screenWidth * 0.015,
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.008,
                                  horizontal: screenWidth * 0.008,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(double screenWidth, double screenHeight) {
    return Container(
      height: screenHeight * 0.15,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.directions_car_rounded,
          size: screenWidth * 0.04,
          color: AppColors.primary.withOpacity(0.5),
        ),
      ),
    );
  }
}
