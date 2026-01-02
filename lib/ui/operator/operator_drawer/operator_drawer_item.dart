import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';

class OperatorDrawerItem extends StatelessWidget {
  final String asset;
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  const OperatorDrawerItem({
    super.key,
    required this.asset,
    required this.title,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Image.asset(
              asset,
              width: 22,
              height: 22,
              color: isSelected ? AppColors.primaryDark : AppColors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Stack(
                children: [
                  if (isSelected)
                    Positioned.fill(
                      right: 40,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(22),
                              bottomRight: Radius.circular(22),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Container(
                    height: 44,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryDark
                            : AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
