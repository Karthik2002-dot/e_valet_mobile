import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

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
              labelText: 'Drivers',
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            TextComponent(
              labelText: 'Manage and monitor all drivers',
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
                          labelText: '24',
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 6),
                        TextComponent(
                          labelText: 'Total Drivers',
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
                          labelText: '18',
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 6),
                        TextComponent(
                          labelText: 'Active Today',
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
