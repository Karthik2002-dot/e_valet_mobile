import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/oauth/login/login.dart';

/// Shown when an operator/scanner selects an outlet but verify-location
/// returns withinBounds: false.
class LocationTooFarScreen extends StatelessWidget {
  final String outletName;
  final double distanceMeters;
  final double allowedRadiusMeters;
  final String? detailMessage;

  const LocationTooFarScreen({
    super.key,
    required this.outletName,
    required this.distanceMeters,
    required this.allowedRadiusMeters,
    this.detailMessage,
  });

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.lightBeigeBackground,
      appBar: const CustomAppBar(),
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
                      size: isTablet ? screenWidth * 0.2 : screenWidth * 0.35,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      'You are too far from the outlet',
                      style: TextStyle(
                        fontSize: isTablet
                            ? screenWidth * 0.04
                            : screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'You must be within the allowed radius to access $outletName.',
                      style: TextStyle(
                        fontSize: isTablet
                            ? screenWidth * 0.025
                            : screenWidth * 0.038,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _InfoRow(
                            label: 'Outlet',
                            value: outletName,
                          ),
                          if (detailMessage != null) ...[
                            SizedBox(height: screenHeight * 0.018),
                            Text(
                              detailMessage!,
                              style: TextStyle(
                                fontSize: isTablet ? 13 : 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                                height: 1.35,
                              ),
                            ),
                          ],
                          if (distanceMeters > 0 || allowedRadiusMeters > 0) ...[
                            SizedBox(height: screenHeight * 0.012),
                            _InfoRow(
                              label: 'Your distance',
                              value: _formatDistance(distanceMeters),
                              valueColor: AppColors.error,
                            ),
                            SizedBox(height: screenHeight * 0.012),
                            _InfoRow(
                              label: 'Allowed radius',
                              value: _formatDistance(allowedRadiusMeters),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        label: const Text(
                          'Back to Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.mutedText,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.black,
            ),
          ),
        ),
      ],
    );
  }
}
