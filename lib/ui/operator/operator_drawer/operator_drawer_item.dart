import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class OperatorDrawerItem extends StatelessWidget {
  final String? asset;
  final IconData? iconData;
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  const OperatorDrawerItem({
    super.key,
    this.asset,
    this.iconData,
    required this.title,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  if (isSelected)
                    Positioned.fill(
                      left: 20,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(22),
                              bottomLeft: Radius.circular(22),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Container(
                    height: 44,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: TextComponent(
                      labelText: title,
                      color: isSelected ? AppColors.black : AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (iconData != null)
              Icon(
                iconData,
                size: 35,
                color: isSelected ? AppColors.black : AppColors.white,
              )
            else if (asset != null)
              Image.asset(
                asset!,
                width: 35,
                height: 35,
                color: isSelected ? AppColors.black : AppColors.white,
              ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
          ],
        ),
      ),
    );
  }
}
