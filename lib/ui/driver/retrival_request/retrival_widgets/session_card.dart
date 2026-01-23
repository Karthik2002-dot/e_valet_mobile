import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class SessionCard extends StatelessWidget {
  final AssignedSession session;
  final VoidCallback? onAccept;

  const SessionCard({super.key, required this.session, this.onAccept});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: session.photoUrl != null
                      ? Image.network(
                          session.photoUrl!,
                          width: double.infinity,
                          height: screenWidth * 0.35,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: screenWidth * 0.35,
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
                                    width: screenWidth * 0.3,
                                    height: screenWidth * 0.3,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          width: double.infinity,
                          height: screenWidth * 0.35,
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
                                width: screenWidth * 0.3,
                                height: screenWidth * 0.3,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.directions_car,
                          size: 20,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
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
                    const SizedBox(height: 12),
                    Divider(
                      color: AppColors.greyLight,
                      thickness: 1,
                      height: 1,
                    ),
                    // Show location if available
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
                              labelText: session.parkingLocation!,
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
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.badge,
                              size: 20,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextComponent(
                                labelText:
                                    '${TextConstants.parkedBy} ${session.parkedBy?.name ?? TextConstants.unknown}',
                                fontSize: screenWidth * 0.04,
                                color: AppColors.black,
                                maxLines: 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            InkWell(
                              onTap: () =>
                                  _makePhoneCall(session.parkedBy?.phone ?? ''),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.phone,
                                  color: AppColors.secondary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }
}
