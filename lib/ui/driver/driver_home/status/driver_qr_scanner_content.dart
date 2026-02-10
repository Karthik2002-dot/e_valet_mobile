import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text_field.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_state.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_state.dart';
import 'package:niloufer_valet_mobile/ui/driver/qr_reader/qr_reader_widget.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/car_photo_intro_screen.dart';

class DriverQrScannerContent extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;
  /// Called when user returns from Car Camera screen so parent can show home (two cards) again.
  final VoidCallback? onReturnFromCarCamera;

  const DriverQrScannerContent({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isDesktop,
    this.onReturnFromCarCamera,
  });

  @override
  State<DriverQrScannerContent> createState() => _DriverQrScannerContentState();
}

class _DriverQrScannerContentState extends State<DriverQrScannerContent> {
  final TextEditingController _tagNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _selectedTab = 0; // 0 = Scan, 1 = Type ID Number
  bool _showCamera = false; // true after 2 sec Lottie intro in scan area
  Timer? _introTimer;
  /// Set when submitting so third screen knows whether to show parking location form (tag) or go straight to Lottie (QR).
  bool _lastSubmissionWasTagNumber = false;

  @override
  void initState() {
    super.initState();
    _introTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showCamera = true);
    });
  }

  @override
  void dispose() {
    _introTimer?.cancel();
    _tagNumberController.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext submitContext) {
    final qrState = submitContext.read<QrBloc>().state;
    if (qrState.qrData != null) {
      _lastSubmissionWasTagNumber = false;
      submitContext.read<TagSubmissionBloc>().add(
            QrCodeSubmitted(qrState.qrData!),
          );
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      final tagNumber = _tagNumberController.text.trim();
      final cardNumber = int.tryParse(tagNumber);
      if (cardNumber == null) {
        SnackBars.showErrorSnackBar(
          submitContext,
          TextConstants.validationEnterValidTagNumber,
        );
        return;
      }
      _lastSubmissionWasTagNumber = true;
      final statusState = submitContext.read<DriverStatusBloc>().state;
      int outletId = int.tryParse(dotenv.env['OUTLET_ID'] ?? '1') ?? 1;
      if (statusState is DriverStatusLoaded) {
        outletId = statusState.status.outletId;
      }
      submitContext.read<TagSubmissionBloc>().add(
            TagNumberSubmitted(outletId: outletId, cardNumber: cardNumber),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QrBloc(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<TagSubmissionBloc, TagSubmissionState>(
            listener: (context, submissionState) {
              if (submissionState is TagSubmissionSuccess) {
                context.read<QrBloc>().add(const QrResetRequested());
                // Third screen: parking location form (if tag) or Carphoto.json 2s, then camera
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CarPhotoIntroScreen(
                      cameViaTagNumber: _lastSubmissionWasTagNumber,
                      onReturnFromCamera: () {
                        widget.onReturnFromCarCamera?.call();
                        if (mounted) {
                          _introTimer?.cancel();
                          setState(() => _showCamera = false);
                          _introTimer = Timer(const Duration(seconds: 2), () {
                            if (mounted) setState(() => _showCamera = true);
                          });
                        }
                      },
                    ),
                  ),
                ).then((_) {
                  // When user returns from third screen (e.g. back before camera): reset and show home
                  widget.onReturnFromCarCamera?.call();
                  if (mounted) {
                    _introTimer?.cancel();
                    setState(() => _showCamera = false);
                    _introTimer = Timer(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _showCamera = true);
                    });
                  }
                });
              }
            },
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // White header with title (like image)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: widget.screenHeight * 0.018),
              color: AppColors.white,
              child: Center(
                child: TextComponent(
                  labelText: TextConstants.vehicleDetailsTitle,
                  fontSize: widget.isDesktop
                      ? widget.screenWidth * 0.022
                      : widget.isTablet
                          ? widget.screenWidth * 0.032
                          : widget.screenWidth * 0.055,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
            SizedBox(height: widget.screenHeight * 0.016),
            // Tabs: Scan | Type Parking Number (same as third screen)
            _buildTabs(),
            SizedBox(height: widget.screenHeight * 0.018),
            Expanded(
              child: _selectedTab == 0
                  ? _buildScanContent()
                  : _buildTypeIdContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final w = widget.screenWidth;
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
              onTap: () => setState(() => _selectedTab = 0),
            ),
          ),
          SizedBox(width: w * 0.025),
          Expanded(
            child: _TabChip(
              icon: Icons.dialpad,
              label: TextConstants.typeParkingNumberTabLabel,
              isActive: !isScan,
              onTap: () => setState(() => _selectedTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  /// Scan tab: full-width/height dark grey container, white-outline frame fills it; QRScan.json for 2s then camera, orange circle button.
  Widget _buildScanContent() {
    final w = widget.screenWidth;
    final h = widget.screenHeight;

    final padding = w * 0.02;
    return LayoutBuilder(
      builder: (context, constraints) {
        final innerW = (constraints.maxWidth - 2 * padding).clamp(0.0, double.infinity);
        final innerH = (constraints.maxHeight - 2 * padding).clamp(0.0, double.infinity);
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(w * 0.04),
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Full container: white-outline frame fills available space; after Lottie, full camera inside it
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
                    child: _showCamera
                        ? QrReaderWidget(
                            screenWidth: widget.screenWidth,
                            screenHeight: widget.screenHeight,
                            isTablet: widget.isTablet,
                            isDesktop: widget.isDesktop,
                            fillWidth: innerW,
                            fillHeight: innerH,
                          )
                        : Lottie.asset(
                            'assets/jsons/QRScan.json',
                            fit: BoxFit.contain,
                            repeat: true,
                          ),
                  ),
                ),
              ),
              // Orange circle button at bottom
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
        );
      },
    );
  }

  Widget _buildTypeIdContent() {
    final w = widget.screenWidth;
    final h = widget.screenHeight;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04),
      child: Column(
        children: [
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
                    labelText: TextConstants.tagNumberLabel,
                    fontSize: w * 0.035,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                  SizedBox(height: h * 0.012),
                  Builder(
                    builder: (ctx) {
                      return TextFieldComponent(
                        labelText: TextConstants.emptyText,
                        hintText: TextConstants.tagNumberHint,
                        controller: _tagNumberController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onSubmitEditing: () => _handleSubmit(ctx),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return TextConstants.validationEnterTagNumber;
                          }
                          if (int.tryParse(value.trim()) == null) {
                            return TextConstants.validationEnterValidNumber;
                          }
                          return null;
                        },
                        borderRadius: w * 0.03,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: h * 0.025),
          SizedBox(
            width: double.infinity,
            height: h * 0.062,
            child: BlocBuilder<TagSubmissionBloc, TagSubmissionState>(
              builder: (context, submissionState) {
                final isLoading = submissionState is TagSubmissionLoading;
                return ElevatedButton(
                  onPressed: isLoading ? null : () => _handleSubmit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.greyLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(w * 0.02),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white),
                          ),
                        )
                      : Row(
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
                );
              },
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
  final VoidCallback onTap;

  const _TabChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
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
