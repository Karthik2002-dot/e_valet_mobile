import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class OperatorDriversScreen extends StatelessWidget {
  const OperatorDriversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextComponent(
              labelText: TextConstants.driversTitle,
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            TextComponent(
              labelText: TextConstants.driversDescription,
              color: AppColors.grey,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextComponent(
                          labelText: TextConstants.totalDriversValue,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 6),
                        TextComponent(
                          labelText: TextConstants.totalDrivers,
                          color: AppColors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextComponent(
                          labelText: TextConstants.activeTodayValue,
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 6),
                        TextComponent(
                          labelText: TextConstants.activeToday,
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
