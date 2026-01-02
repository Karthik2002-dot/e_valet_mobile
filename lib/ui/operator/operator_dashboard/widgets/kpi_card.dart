import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextComponent(
            labelText: title,
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 8),
          TextComponent(
            labelText: value,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
