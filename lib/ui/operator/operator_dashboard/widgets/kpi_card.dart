import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextComponent(
            labelText: title,
            textAlign: TextAlign.center,
            color: AppColors.black,
            fontSize: MediaQuery.of(context).size.width * 0.01,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(
            height: 12,
          ),
          TextComponent(
            labelText: value,
            textAlign: TextAlign.center,
            color: AppColors.black,
            fontSize: MediaQuery.of(context).size.width * 0.015,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
