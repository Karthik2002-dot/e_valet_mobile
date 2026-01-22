import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/digital_key_rack_response.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_slots/widgets/parked_car_card.dart';

class SlotsContentView extends StatelessWidget {
  final DigitalKeyRackResponse digitalKeyRack;
  final Function(int cardNumber, String sessionId)? onManualRequest;

  const SlotsContentView({
    super.key,
    required this.digitalKeyRack,
    this.onManualRequest,
  });

  @override
  Widget build(BuildContext context) {
    final occupiedSlots = digitalKeyRack.keyRack.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              crossAxisSpacing: MediaQuery.of(context).size.width * 0.02,
              mainAxisSpacing: MediaQuery.of(context).size.height * 0.02,
              childAspectRatio: 0.7,
            ),
            itemCount: digitalKeyRack.keyRack.length,
            itemBuilder: (context, index) {
              final item = digitalKeyRack.keyRack[index];
              return ParkedCarCard(
                item: item,
                onManualRequest: onManualRequest,
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
                  labelText: TextConstants.noCarsParked,
                  fontSize: MediaQuery.of(context).size.width * 0.018,
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
