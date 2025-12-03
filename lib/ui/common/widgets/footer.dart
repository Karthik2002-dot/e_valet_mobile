import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/color.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextComponent(
            labelText: 'Powered By',
            fontSize: 12,
            color: AppColors.mutedText,
          ),
          const SizedBox(width: 8),
          // Yathi logo
          Image.asset(
            'assets/images/YathiLogo.png',
            height: 24,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
