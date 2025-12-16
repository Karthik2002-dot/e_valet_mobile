import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: MediaQuery.of(context).size.height * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextComponent(
            labelText: TextConstants.poweredBy,
            fontSize: MediaQuery.of(context).size.width * 0.03,
            color: AppColors.mutedText,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.02,
          ),
          // Yathi logo
          Image.asset(
            'assets/images/YathiLogo.png',
            height: MediaQuery.of(context).size.width * 0.04,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
