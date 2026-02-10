import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text_field.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_camera_screen.dart';

/// Third screen in park flow: same layout as second screen (Vehicle details + Scan | Type Parking Number).
/// - Scan tab: dark grey area with Carphoto.json for 2 seconds, then camera opens.
/// - Type Parking Number tab: parking location form; on submit → Carphoto.json 2 sec then camera.
class CarPhotoIntroScreen extends StatefulWidget {
  final bool cameViaTagNumber;
  final VoidCallback? onReturnFromCamera;

  const CarPhotoIntroScreen({
    super.key,
    required this.cameViaTagNumber,
    this.onReturnFromCamera,
  });

  @override
  State<CarPhotoIntroScreen> createState() => _CarPhotoIntroScreenState();
}

class _CarPhotoIntroScreenState extends State<CarPhotoIntroScreen> {
  final TextEditingController _parkingLocationController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// 0 = Scan (Carphoto.json), 1 = Type Parking Number (form)
  int _selectedTab = 0;
  /// true when showing Carphoto.json and 2 sec timer is running before opening camera
  bool _showLottieThenCamera = false;
  String? _parkingLocationForCamera;
  Timer? _lottieTimer;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.cameViaTagNumber ? 1 : 0;
    if (!widget.cameViaTagNumber) {
      _showLottieThenCamera = true;
      _startLottieTimer();
    }
  }

  void _startLottieTimer() {
    _lottieTimer?.cancel();
    _lottieTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      _lottieTimer = null;
      _openCamera(_parkingLocationForCamera);
    });
  }

  void _openCamera(String? initialParkingLocation) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarCameraScreen(
          sessionId: null,
          preventBackNavigation: true,
          initialParkingLocation: initialParkingLocation,
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onReturnFromCamera?.call();
    });
  }

  void _onSubmitParkingLocation() {
    if (_formKey.currentState?.validate() ?? false) {
      final location = _parkingLocationController.text.trim();
      if (location.isEmpty) {
        SnackBars.showErrorSnackBar(
          context,
          TextConstants.pleaseEnterParkingLocation,
        );
        return;
      }
      setState(() {
        _parkingLocationForCamera = location;
        _showLottieThenCamera = true;
        _selectedTab = 0; // switch to Scan tab to show Carphoto.json
      });
      _startLottieTimer();
    }
  }

  @override
  void dispose() {
    _lottieTimer?.cancel();
    _parkingLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.lightBeigeBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Same header as second screen: Vehicle details
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: h * 0.018),
              color: AppColors.white,
              child: Center(
                child: TextComponent(
                  labelText: TextConstants.vehicleDetailsTitle,
                  fontSize: w * 0.055,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
            SizedBox(height: h * 0.016),
            // Tabs: Scan | Type Parking Number (same as second screen)
            _buildTabs(w),
            SizedBox(height: h * 0.018),
            Expanded(
              child: _selectedTab == 0
                  ? _buildScanTabContent(w, h)
                  : _buildTypeParkingNumberContent(w, h),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(double w) {
    final isScan = _selectedTab == 0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.02),
      child: Row(
        children: [
          Expanded(
            child: _TabChip(
              icon: Icons.qr_code_scanner,
              label: TextConstants.scanTabLabel,
              isActive: isScan,
              onTap: _showLottieThenCamera
                  ? null
                  : () => setState(() => _selectedTab = 0),
            ),
          ),
          SizedBox(width: w * 0.025),
          Expanded(
            child: _TabChip(
              icon: Icons.dialpad,
              label: TextConstants.typeParkingNumberTabLabel,
              isActive: !isScan,
              onTap: _showLottieThenCamera
                  ? null
                  : () => setState(() => _selectedTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  /// Scan tab: dark grey area, white-outline frame, Carphoto.json, orange circle at bottom (exact like image)
  Widget _buildScanTabContent(double w, double h) {
    final padding = w * 0.02;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(w * 0.04),
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(w * 0.04),
                    border: Border.all(color: AppColors.white, width: 2.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Lottie.asset(
                    'assets/jsons/Carphoto.json',
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: h * 0.018,
              child: Container(
                width: w * 0.2,
                height: w * 0.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.actionButtonYellow,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Type Parking Number tab: same form as design (Enter the Parking Location to Proceed, etc.)
  Widget _buildTypeParkingNumberContent(double w, double h) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextComponent(
            labelText: TextConstants.enterParkingLocationToProceed,
            fontSize: w * 0.045,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          SizedBox(height: h * 0.02),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(w * 0.03),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow10,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextComponent(
                    labelText: TextConstants.parkingLocationLabel,
                    fontSize: w * 0.035,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                  SizedBox(height: h * 0.012),
                  TextFieldComponent(
                    labelText: TextConstants.emptyText,
                    hintText: TextConstants.parkingLocationHint,
                    controller: _parkingLocationController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onSubmitEditing: _onSubmitParkingLocation,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return TextConstants.pleaseEnterParkingLocation;
                      }
                      return null;
                    },
                    borderRadius: w * 0.03,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: h * 0.025),
          SizedBox(
            width: double.infinity,
            height: h * 0.062,
            child: ElevatedButton(
              onPressed: _onSubmitParkingLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.actionButtonYellow,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.greyLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w * 0.025),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextComponent(
                    labelText: TextConstants.submitButton,
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                  SizedBox(width: w * 0.02),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.white,
                    size: w * 0.05,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: h * 0.02),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _TabChip({
    required this.icon,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.actionButtonYellow : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.divider,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 1),
                ),
                child: Icon(icon, color: AppColors.white, size: 20),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
