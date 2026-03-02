import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_event.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/driver_home.dart';

/// Shown when login succeeds but clock-in fails because the driver is too far from the outlet.
/// Displays the API message (e.g. distance / allowed) and a button to continue to driver home (offline).
class ClockInTooFarScreen extends StatelessWidget {
  final String message;

  const ClockInTooFarScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTranslationsNotifier>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return Scaffold(
      backgroundColor: AppColors.lightBeigeBackground,
      appBar: const CustomAppBar(
        showLanguageIcon: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.06),
                    Icon(
                      Icons.location_off_rounded,
                      size: isDesktop
                          ? screenWidth * 0.12
                          : isTablet
                              ? screenWidth * 0.2
                              : screenWidth * 0.35,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    TextComponent(
                      labelText: t.get(TextConstants.clockInTooFarTitle),
                      fontSize: isDesktop
                          ? screenWidth * 0.022
                          : isTablet
                              ? screenWidth * 0.04
                              : screenWidth * 0.055,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextComponent(
                      labelText: t.get(TextConstants.clockInTooFarSubtitle),
                      fontSize: isDesktop
                          ? screenWidth * 0.014
                          : isTablet
                              ? screenWidth * 0.025
                              : screenWidth * 0.038,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.025,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.grey.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextComponent(
                        labelText: message,
                        fontSize: isDesktop
                            ? screenWidth * 0.013
                            : isTablet
                                ? screenWidth * 0.022
                                : screenWidth * 0.035,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SafeArea(
              top: false,
              child: Footer(),
            ),
          ],
        ),
      ),
    );
  }
}
