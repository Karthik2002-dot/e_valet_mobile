import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/driver/session/pass_available_driver.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/driver/retrival_request/retrival_widgets/driver_card.dart';

class PassToDriverSection extends StatelessWidget {
  final double screenWidth;
  final bool isDriversLoading;
  final List<PassAvailableDriver> drivers;
  final String? passingDriverId;
  final void Function(PassAvailableDriver driver)? onPassToDriver;

  const PassToDriverSection({
    super.key,
    required this.screenWidth,
    required this.isDriversLoading,
    required this.drivers,
    required this.passingDriverId,
    required this.onPassToDriver,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(color: AppColors.divider, height: 24),

        // Section header
        Row(
          children: [
            const Icon(Icons.swap_horiz_rounded,
                size: 18, color: AppColors.mutedText),
            const SizedBox(width: 6),
            Text(
              'Pass to Another Driver',
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (isDriversLoading) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ] else if (drivers.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No other drivers available at this time.',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: AppColors.mutedText,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ] else ...[
          // Two-column grid — build rows of two manually so the grid is
          // non-scrollable and fits inside the parent SingleChildScrollView.
          for (int i = 0; i < drivers.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: DriverCard(
                      driver: drivers[i],
                      screenWidth: screenWidth,
                      isPassing: passingDriverId == drivers[i].userId,
                      isAnyPassing: passingDriverId != null,
                      onTap: onPassToDriver != null
                          ? () => onPassToDriver!(drivers[i])
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Second card — or an empty spacer if count is odd
                  if (i + 1 < drivers.length)
                    Expanded(
                      child: DriverCard(
                        driver: drivers[i + 1],
                        screenWidth: screenWidth,
                        isPassing: passingDriverId == drivers[i + 1].userId,
                        isAnyPassing: passingDriverId != null,
                        onTap: onPassToDriver != null
                            ? () => onPassToDriver!(drivers[i + 1])
                            : null,
                      ),
                    )
                  else
                    const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
