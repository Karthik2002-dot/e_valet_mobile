import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/driver_header_widget.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/driver_online_content.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/driver_offline_content.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/driver_break_content.dart';

class DriverHomeContent extends StatelessWidget {
  final String driverName;
  final bool isOnBreak;
  final bool isOnline;

  const DriverHomeContent({
    super.key,
    required this.driverName,
    required this.isOnBreak,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    final logoSize = isDesktop
        ? screenWidth * 0.08
        : isTablet
            ? screenWidth * 0.12
            : screenWidth * 0.2;

    final iconSize = isDesktop
        ? screenWidth * 0.02
        : isTablet
            ? screenWidth * 0.035
            : screenWidth * 0.06;

    return Scaffold(
      backgroundColor: AppColors.lightBeigeBackground,
      // Use CustomAppBar with language icon and menu
      appBar: CustomAppBar(
        showLanguageIcon: true,
        logoSize: logoSize,
        iconSize: iconSize,
      ),
      body: Column(
        children: [
          // Header Content Section (status card)
          DriverHeaderWidget(
            isOnline: isOnline,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            isTablet: isTablet,
            isDesktop: isDesktop,
          ),
          // Main Content Section with SafeArea
          Expanded(
            child: SafeArea(
              top: false,
              child: Container(
                color: AppColors.lightBeigeBackground,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                    ),
                    child: isOnBreak
                        ? DriverBreakContent(
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            isTablet: isTablet,
                            isDesktop: isDesktop,
                          )
                        : isOnline
                            ? DriverOnlineContent(
                                driverName: driverName,
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                                isTablet: isTablet,
                                isDesktop: isDesktop,
                              )
                            : DriverOfflineContent(
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                                isTablet: isTablet,
                                isDesktop: isDesktop,
                              ),
                  ),
                ),
              ),
            ),
          ),
          // Footer
          SafeArea(
            top: false,
            child: const Footer(),
          ),
        ],
      ),
    );
  }
}
