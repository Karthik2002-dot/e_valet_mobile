import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/digital_key_rack_response.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class SlotsContentView extends StatelessWidget {
  final DigitalKeyRackResponse digitalKeyRack;

  const SlotsContentView({
    super.key,
    required this.digitalKeyRack,
  });

  @override
  Widget build(BuildContext context) {
    final totalSlots = digitalKeyRack.total;
    final occupiedSlots = digitalKeyRack.keyRack.length;
    final availableSlots = totalSlots - occupiedSlots;

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextComponent(
            labelText: TextConstants.parkingSlotsTitle,
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.width * 0.022,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          TextComponent(
            labelText: TextConstants.parkingSlotsDescription,
            color: AppColors.grey,
            fontSize: MediaQuery.of(context).size.width * 0.016,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextComponent(
                        labelText: '$availableSlots',
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize:
                            MediaQuery.of(context).size.width * 0.03,
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.008,
                      ),
                      TextComponent(
                        labelText: TextConstants.available,
                        color: AppColors.grey,
                        fontSize:
                            MediaQuery.of(context).size.width * 0.016,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.015,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextComponent(
                        labelText: '$occupiedSlots',
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize:
                            MediaQuery.of(context).size.width * 0.03,
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.008,
                      ),
                      TextComponent(
                        labelText: TextConstants.occupied,
                        color: AppColors.grey,
                        fontSize:
                            MediaQuery.of(context).size.width * 0.016,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.015,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextComponent(
                        labelText: '$totalSlots',
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize:
                            MediaQuery.of(context).size.width * 0.03,
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.008,
                      ),
                      TextComponent(
                        labelText: 'Total Slots',
                        color: AppColors.grey,
                        fontSize:
                            MediaQuery.of(context).size.width * 0.016,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          // Occupied Slots Grid
          if (occupiedSlots > 0) ...[
            TextComponent(
              labelText: 'Occupied Slots ($occupiedSlots)',
              color: AppColors.black,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width * 0.02,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing:
                    MediaQuery.of(context).size.width * 0.015,
                mainAxisSpacing:
                    MediaQuery.of(context).size.height * 0.015,
                childAspectRatio: 0.85,
              ),
              itemCount: digitalKeyRack.keyRack.length,
              itemBuilder: (context, index) {
                final item = digitalKeyRack.keyRack[index];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vehicle Image
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: Image.network(
                          item.photoUrl,
                          height:
                              MediaQuery.of(context).size.height * 0.1,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height:
                                  MediaQuery.of(context).size.height *
                                      0.1,
                              color: AppColors.grey.withOpacity(0.2),
                              child: Icon(
                                Icons.directions_car,
                                size:
                                    MediaQuery.of(context).size.width *
                                        0.03,
                                color: AppColors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                      // Card Info
                      Padding(
                        padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.006,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                TextComponent(
                                  labelText: 'Card #${item.cardNumber}',
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context)
                                          .size
                                          .width *
                                      0.012,
                                  color: AppColors.black,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: MediaQuery.of(context)
                                            .size
                                            .width *
                                        0.006,
                                    vertical: MediaQuery.of(context)
                                            .size
                                            .height *
                                        0.002,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: TextComponent(
                                    labelText: item.duration,
                                    fontSize: MediaQuery.of(context)
                                            .size
                                            .width *
                                        0.008,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height *
                                      0.005,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: MediaQuery.of(context)
                                          .size
                                          .width *
                                      0.01,
                                  color: AppColors.grey,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context)
                                          .size
                                          .width *
                                      0.003,
                                ),
                                Expanded(
                                  child: TextComponent(
                                    labelText: item.parkedAt,
                                    fontSize: MediaQuery.of(context)
                                            .size
                                            .width *
                                        0.008,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ] else ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Icon(
                    Icons.check_circle_outline,
                    size: MediaQuery.of(context).size.width * 0.06,
                    color: AppColors.grey,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  TextComponent(
                    labelText: 'All slots are currently available',
                    fontSize: MediaQuery.of(context).size.width * 0.018,
                    color: AppColors.grey,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
