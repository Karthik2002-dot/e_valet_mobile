import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/color.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/texts.dart';

class QrScreenHeader extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final double headerHeight;

  const QrScreenHeader({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.headerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: headerHeight,
      color: AppColors.headerYellow,
      padding: EdgeInsets.only(
        left: screenWidth * 0.03,
        right: screenWidth * 0.03,
        top: MediaQuery.of(context).padding.top * 0.6 + screenHeight * 0.005,
        bottom: screenHeight * 0.012,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/niloufer.logo.png',
                  height: screenHeight * 0.05,
                  fit: BoxFit.contain,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.text_fields,
                      color: AppColors.white,
                      size: screenWidth * 0.05,
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: AppColors.white,
                      size: screenWidth * 0.05,
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.006),
          BlocBuilder<QrBloc, QrState>(
            builder: (context, state) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextComponent(
                          labelText: AppTexts.headerWelcome,
                          fontSize: screenWidth * 0.035,
                          color: AppColors.white,
                          fontWeight: FontWeight.w400,
                        ),
                        SizedBox(height: screenHeight * 0.004),
                        TextComponent(
                          labelText: AppTexts.headerName,
                          fontSize: screenWidth * 0.052,
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      TextComponent(
                        labelText: AppTexts.headerOnBreak,
                        fontSize: screenWidth * 0.04,
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Transform.scale(
                        scale: 0.75,
                        child: Switch(
                          value: state.isOnBreak,
                          onChanged: (value) =>
                              context.read<QrBloc>().add(QrBreakToggled(value)),
                          activeColor: AppColors.white,
                          activeTrackColor: AppColors.grey.withOpacity(0.6),
                          inactiveThumbColor: AppColors.grey,
                          inactiveTrackColor: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: screenHeight * 0.002),
          BlocBuilder<QrBloc, QrState>(
            builder: (context, state) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.032,
                  vertical: screenHeight * 0.0028,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.power_settings_new,
                          color: const Color(0xFF4A4A4A),
                          size: screenWidth * 0.045,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        TextComponent(
                          labelText: AppTexts.statusLabel,
                          fontSize: screenWidth * 0.04,
                          color: const Color(0xFF4A4A4A),
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (state.isLoading)
                          Padding(
                            padding: EdgeInsets.only(
                              right: screenWidth * 0.015,
                            ),
                            child: const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        TextComponent(
                          labelText: state.isOnline
                              ? AppTexts.statusOnline
                              : AppTexts.statusOffline,
                          fontSize: screenWidth * 0.04,
                          color: const Color(0xFF4A4A4A),
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(width: screenWidth * 0.025),
                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: state.isOnline,
                            onChanged: (value) => context
                                .read<QrBloc>()
                                .add(QrStatusToggled(value)),
                            activeColor: AppColors.white,
                            activeTrackColor: const Color(0xFF2ECC71),
                            inactiveThumbColor: AppColors.grey,
                            inactiveTrackColor: AppColors.grey.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
