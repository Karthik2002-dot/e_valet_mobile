import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/skeleton_loader.dart';

class ValetKpiCard extends StatelessWidget {
  final String value;
  final String label;
  final bool isLoading;

  const ValetKpiCard({
    super.key,
    required this.value,
    required this.label,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isLoading
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLoader(
                  height: MediaQuery.of(context).size.height * 0.015,
                  width: MediaQuery.of(context).size.width * 0.12,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  height: MediaQuery.of(context).size.height * 0.03,
                  width: MediaQuery.of(context).size.width * 0.08,
                  borderRadius: 4,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextComponent(
                  labelText: label,
                  color: AppColors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.013,
                ),
                const SizedBox(height: 8),
                TextComponent(
                  labelText: value,
                  color: AppColors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
    );
  }
}
