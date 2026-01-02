import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class OperatorCarLogsScreen extends StatelessWidget {
  const OperatorCarLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextComponent(
              labelText: TextConstants.carLogsTitle,
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            TextComponent(
              labelText: TextConstants.carLogsDescription,
              color: AppColors.grey,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextComponent(
                          labelText: TextConstants.totalTripsValue,
                        ),
                        const SizedBox(height: 6),
                        TextComponent(
                          labelText: TextConstants.totalTrips,
                          color: AppColors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextComponent(
                          labelText: TextConstants.totalDistanceValue,
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 6),
                        TextComponent(
                          labelText: TextConstants.totalDistance,
                          color: AppColors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
