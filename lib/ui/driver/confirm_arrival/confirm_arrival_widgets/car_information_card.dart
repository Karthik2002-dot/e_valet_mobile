import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class CarInformationCard extends StatelessWidget {
  final AssignedSession session;

  /// When true, uses smaller image (e.g. when showing handover buttons).
  final bool compact;

  const CarInformationCard({
    super.key,
    required this.session,
    this.compact = false,
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
          // Details Section (above image) — smaller text when compact
          Padding(
            padding: EdgeInsets.all(
                compact ? screenWidth * 0.03 : screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge Number
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: compact ? screenWidth * 0.045 : screenWidth * 0.06,
                      color: AppColors.secondary,
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    TextComponent(
                      labelText: TextConstants.badgeNumber,
                      fontSize:
                          compact ? screenWidth * 0.028 : screenWidth * 0.035,
                      color: AppColors.grey,
                    ),
                    Spacer(),
                    TextComponent(
                      labelText: session.cardNumber.toString(),
                      fontSize:
                          compact ? screenWidth * 0.038 : screenWidth * 0.05,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ],
                ),

                SizedBox(
                    height:
                        compact ? screenHeight * 0.01 : screenHeight * 0.02),

                Divider(
                  color: AppColors.greyLight,
                  thickness: 1,
                  height: 1,
                ),
                if (session.parkingLocation.isNotEmpty) ...[
                  SizedBox(height: compact ? 4 : 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: compact ? 16 : 20,
                        color: AppColors.secondary,
                      ),
                      SizedBox(width: compact ? 6 : 8),
                      Expanded(
                        child: TextComponent(
                          labelText: session.parkingLocation.toString(),
                          fontSize: compact
                              ? screenWidth * 0.032
                              : screenWidth * 0.04,
                          color: AppColors.black,
                          maxLines: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 8 : 12),
                  Divider(
                    color: AppColors.greyLight,
                    thickness: 1,
                    height: 1,
                  ),
                ],

                SizedBox(
                    height:
                        compact ? screenHeight * 0.01 : screenHeight * 0.02),

                // Parked By
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.badge,
                      size: compact ? screenWidth * 0.045 : screenWidth * 0.06,
                      color: AppColors.secondary,
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    TextComponent(
                      labelText: TextConstants.parkedByLabel,
                      fontSize:
                          compact ? screenWidth * 0.028 : screenWidth * 0.035,
                      color: AppColors.grey,
                    ),
                    if (!compact) SizedBox(height: screenHeight * 0.01),
                    TextComponent(
                      labelText:
                          session.parkedBy?.name ?? TextConstants.unknown,
                      fontSize:
                          compact ? screenWidth * 0.032 : screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                    Spacer(),
                    // Phone Icon
                    IconButton(
                      padding: compact ? const EdgeInsets.all(4) : null,
                      constraints: compact
                          ? const BoxConstraints(minWidth: 32, minHeight: 32)
                          : null,
                      onPressed: () =>
                          _makePhoneCall(session.parkedBy?.phone ?? ''),
                      icon: Icon(
                        Icons.phone,
                        color: AppColors.secondary,
                        size:
                            compact ? screenWidth * 0.045 : screenWidth * 0.06,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Car Image (below details) — always visible; medium when compact, large otherwise
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.black,
                width: 2,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
              color: AppColors.white,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
              child: session.photoUrl != null
                  ? Image.network(
                      session.photoUrl!,
                      width: double.infinity,
                      height: compact ? screenWidth * 0.45 : screenWidth * 0.6,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height:
                              compact ? screenWidth * 0.45 : screenWidth * 0.6,
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
                      height: compact ? screenWidth * 0.45 : screenWidth * 0.6,
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
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }
}

/// Small image section for 20% proportional layout (image on top).
class CarImageSection extends StatelessWidget {
  final AssignedSession session;

  const CarImageSection({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow10,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: session.photoUrl != null
            ? Image.network(
                session.photoUrl!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _placeholder(context),
              )
            : _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      color: AppColors.white,
      child: Center(
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            -1,
            0,
            0,
            0,
            255,
            0,
            -1,
            0,
            0,
            255,
            0,
            0,
            -1,
            0,
            255,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: Image.asset(
            'assets/images/cars.png',
            fit: BoxFit.contain,
            width: screenWidth * 0.25,
            height: screenHeight * 0.1,
          ),
        ),
      ),
    );
  }
}

/// Details-only section for 20% proportional layout (data below image).
class CarDetailsSection extends StatelessWidget {
  final AssignedSession session;

  const CarDetailsSection({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow10,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car,
                    size: screenWidth * 0.04, color: AppColors.secondary),
                SizedBox(width: screenWidth * 0.02),
                TextComponent(
                  labelText: TextConstants.badgeNumber,
                  fontSize: screenWidth * 0.028,
                  color: AppColors.grey,
                ),
                const Spacer(),
                TextComponent(
                  labelText: session.cardNumber.toString(),
                  fontSize: screenWidth * 0.032,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ],
            ),
            if (session.parkingLocation.isNotEmpty) ...[
              SizedBox(height: screenWidth * 0.015),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on,
                      size: screenWidth * 0.035, color: AppColors.secondary),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: TextComponent(
                      labelText: session.parkingLocation,
                      fontSize: screenWidth * 0.028,
                      color: AppColors.black,
                      maxLines: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: screenWidth * 0.015),
            Row(
              children: [
                Icon(Icons.badge,
                    size: screenWidth * 0.04, color: AppColors.secondary),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: TextComponent(
                    labelText:
                        '${TextConstants.parkedByLabel} ${session.parkedBy?.name ?? TextConstants.unknown}',
                    fontSize: screenWidth * 0.028,
                    color: AppColors.black,
                    maxLines: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  padding: const EdgeInsets.all(4),
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () => FlutterPhoneDirectCaller.callNumber(
                      session.parkedBy?.phone ?? ''),
                  icon: Icon(Icons.phone,
                      color: AppColors.secondary, size: screenWidth * 0.04),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
