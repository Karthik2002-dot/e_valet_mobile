import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/operator_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/operator_menu_event.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class OperatorStatusCardWidget extends StatelessWidget {
  final bool isOnline;
  final double screenWidth;
  final bool isTablet;
  final bool isDesktop;

  const OperatorStatusCardWidget({
    super.key,
    required this.isOnline,
    required this.screenWidth,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: (267 * screenWidth / 360).clamp(267.0, screenWidth * 0.9),
        height:
            (40.3 * MediaQuery.of(context).size.height / 800).clamp(40.3, 57.0),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: 0,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.power_settings_new,
                    color: AppColors.black,
                    size: isDesktop
                        ? screenWidth * 0.015
                        : isTablet
                            ? screenWidth * 0.025
                            : screenWidth * 0.045,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  TextComponent(
                    labelText: TextConstants.statusLabel,
                    fontSize: isDesktop
                        ? screenWidth * 0.014
                        : isTablet
                            ? screenWidth * 0.022
                            : screenWidth * 0.038,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ],
              ),
              Row(
                children: [
                  TextComponent(
                    labelText: isOnline
                        ? TextConstants.statusOnline
                        : TextConstants.statusOffline,
                    fontSize: isDesktop
                        ? screenWidth * 0.014
                        : isTablet
                            ? screenWidth * 0.022
                            : screenWidth * 0.038,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Transform.scale(
                    scale: isDesktop
                        ? 0.75
                        : isTablet
                            ? 0.85
                            : 0.9,
                    child: Switch(
                      value: isOnline,
                      onChanged: (value) {
                        context
                            .read<OperatorMenuBloc>()
                            .add(OperatorOnlineStatusToggled(value));
                      },
                      activeColor: AppColors.success,
                      inactiveThumbColor: AppColors.grey,
                      inactiveTrackColor: AppColors.greyLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

