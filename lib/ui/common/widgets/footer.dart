import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final horizontalPadding =
            isTablet ? 24.0 : MediaQuery.of(context).size.width * 0.05;
        final verticalPadding =
            isTablet ? 12.0 : MediaQuery.of(context).size.height * 0.02;
        final poweredByFontSize =
            isTablet ? 12.0 : MediaQuery.of(context).size.width * 0.03;
        final spacerWidth =
            isTablet ? 12.0 : MediaQuery.of(context).size.width * 0.02;
        final logoHeight =
            MediaQuery.of(context).size.width * (isTablet ? 0.02 : 0.04);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextComponent(
                labelText: TextConstants.poweredBy,
                fontSize: poweredByFontSize,
                color: AppColors.mutedText,
              ),
              SizedBox(width: spacerWidth),
              // Yathi logo
              Image.asset(
                'assets/images/YathiLogo.png',
                height: logoHeight,
                fit: BoxFit.contain,
              ),
            ],
          ),
        );
      },
    );
  }
}
