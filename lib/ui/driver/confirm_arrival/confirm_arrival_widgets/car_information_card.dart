import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class CarInformationCard extends StatelessWidget {
  final AssignedSession session;

  const CarInformationCard({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow10,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Car Image
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.black,
                width: 2,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              color: AppColors.white,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: session.photoUrl != null
                  ? Image.network(
                      session.photoUrl!,
                      width: double.infinity,
                      height: screenWidth * 0.6,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: screenWidth * 0.6,
                          color: AppColors.white,
                          child: Center(
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                -1, 0, 0, 0, 255, // Red channel inverted
                                0, -1, 0, 0, 255, // Green channel inverted
                                0, 0, -1, 0, 255, // Blue channel inverted
                                0, 0, 0, 1, 0, // Alpha channel unchanged
                              ]),
                              child: Image.asset(
                                'assets/images/cars.png',
                                fit: BoxFit.contain,
                                width: screenWidth * 0.4,
                                height: screenHeight * 0.4,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      width: double.infinity,
                      height: screenWidth * 0.6,
                      color: AppColors.white,
                      child: Center(
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.matrix([
                            -1, 0, 0, 0, 255, // Red channel inverted
                            0, -1, 0, 0, 255, // Green channel inverted
                            0, 0, -1, 0, 255, // Blue channel inverted
                            0, 0, 0, 1, 0, // Alpha channel unchanged
                          ]),
                          child: Image.asset(
                            'assets/images/cars.png',
                            fit: BoxFit.contain,
                            width: screenWidth * 0.4,
                            height: screenHeight * 0.4,
                          ),
                        ),
                      ),
                    ),
            ),
          ),

          // Details Section
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge Number
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: screenWidth * 0.06,
                      color: AppColors.secondary,
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    TextComponent(
                      labelText: TextConstants.badgeNumber,
                      fontSize: screenWidth * 0.035,
                      color: AppColors.grey,
                    ),
                    Spacer(),
                    TextComponent(
                      labelText: session.cardNumber.toString(),
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),

                Divider(
                  color: AppColors.greyLight,
                  thickness: 1,
                  height: 1,
                ),
                if (session.parkingLocation != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 20,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextComponent(
                          labelText: session.parkingLocation.toString(),
                          fontSize: screenWidth * 0.04,
                          color: AppColors.black,
                          maxLines: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    color: AppColors.greyLight,
                    thickness: 1,
                    height: 1,
                  ),
                ],

                SizedBox(height: screenHeight * 0.02),

                // Parked By
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.badge,
                      size: screenWidth * 0.06,
                      color: AppColors.secondary,
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    TextComponent(
                      labelText: TextConstants.parkedByLabel,
                      fontSize: screenWidth * 0.035,
                      color: AppColors.grey,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextComponent(
                      labelText:
                          session.parkedBy?.name ?? TextConstants.unknown,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                    Spacer(),
                    // Phone Icon
                    IconButton(
                      onPressed: () =>
                          _makePhoneCall(session.parkedBy?.phone ?? ''),
                      icon: Icon(
                        Icons.phone,
                        color: AppColors.secondary,
                        size: screenWidth * 0.06,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),

                // Locate Car Button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.greyLight,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: screenWidth * 0.05,
                        color: AppColors.secondary,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      TextComponent(
                        labelText: TextConstants.locateCarUsingPhoto,
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }
}
