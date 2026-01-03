import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/key_rack_item.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class DigitalKeyRackCard extends StatelessWidget {
  final KeyRackItem keyRackItem;

  const DigitalKeyRackCard({
    super.key,
    required this.keyRackItem,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardRadius = 16.0;

    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.015),
      height: size.width * 0.2, // card height similar to sample
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius),
        child: Stack(
          children: [
            // Background image (full card)
            Positioned.fill(
              child: Image.network(
                keyRackItem.photoUrl,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[900],
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.directions_car,
                      size: size.width * 0.09,
                      color: Colors.grey[500],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[900],
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white70,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Dark gradient overlay for better text contrast
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                    ],
                  ),
                ),
              ),
            ),

            // Card number badge (top-left)
            Positioned(
              top: size.height * 0.01,
              left: size.width * 0.01,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02,
                  vertical: size.height * 0.004,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextComponent(
                  labelText: '#${keyRackItem.cardNumber}',
                  fontSize: size.width * 0.02,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Bottom-left text (brand + slot)
            Positioned(
              left: size.width * 0.02,
              bottom: size.height * 0.012,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextComponent(
                    // example: Honda
                    labelText: keyRackItem.cardNumber.toString(),
                    fontSize: size.width * 0.03,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(
                    height: size.height * 0.003,
                  ),
                  TextComponent(
                    // example: A-12
                    labelText: keyRackItem.parkedBy,
                    fontSize: size.width * 0.02,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
