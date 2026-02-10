import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_state.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/driver_qr_scanner_content.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/oauth/login/login.dart';

class DriverOnlineContent extends StatefulWidget {
  final String driverName;
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;
  final bool showParkFlow;
  final ValueChanged<bool> onParkFlowChanged;

  const DriverOnlineContent({
    super.key,
    required this.driverName,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isDesktop,
    required this.showParkFlow,
    required this.onParkFlowChanged,
  });

  @override
  State<DriverOnlineContent> createState() => _DriverOnlineContentState();
}

class _DriverOnlineContentState extends State<DriverOnlineContent>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When user reopens the app (brings to foreground), parent resets showParkFlow via key reset.
  }

  /// First screen: two cards (Park Vehicle | Retrieve Vehicle). Park tappable → Vehicle details.
  Widget _buildFirstScreen() {
    final w = widget.screenWidth;
    final h = widget.screenHeight;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04),
              child: Column(
                children: [
                  SizedBox(height: h * 0.03),
                  _buildActionCard(
                    imagePath: 'assets/images/park.png',
                    buttonLabel: TextConstants.parkVehicle,
                    onTap: () => widget.onParkFlowChanged(true),
                  ),
                  SizedBox(height: h * 0.04),
                  _buildActionCard(
                    imagePath: 'assets/images/retrive.png',
                    buttonLabel: TextConstants.retrieveVehicle,
                    onTap: null,
                  ),
                  SizedBox(height: h * 0.025),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String imagePath,
    required String buttonLabel,
    VoidCallback? onTap,
  }) {
    final w = widget.screenWidth;
    final h = widget.screenHeight;
    final isTappable = onTap != null;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(w * 0.045),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow10,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isTappable ? onTap : null,
          borderRadius: BorderRadius.circular(w * 0.045),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.045,
              vertical: h * 0.014,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: h * 0.22,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: h * 0.024),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: h * 0.018),
                  decoration: BoxDecoration(
                    color: AppColors.actionButtonYellow,
                    borderRadius: BorderRadius.circular(w * 0.025),
                  ),
                  child: Center(
                    child: TextComponent(
                      labelText: buttonLabel,
                      fontSize: widget.isDesktop
                          ? w * 0.018
                          : widget.isTablet
                              ? w * 0.028
                              : w * 0.048,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleDetailsScreen() {
    return Column(
      children: [
        Expanded(
          child: DriverQrScannerContent(
            key: ValueKey('vehicle_details'),
            screenWidth: widget.screenWidth,
            screenHeight: widget.screenHeight,
            isTablet: widget.isTablet,
            isDesktop: widget.isDesktop,
            onReturnFromCarCamera: () => widget.onParkFlowChanged(false),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TagSubmissionBloc(),
      child: BlocListener<TagSubmissionBloc, TagSubmissionState>(
        listener: (context, state) {
          if (state is TagSubmissionSuccess) {
            SnackBars.showSuccessSnackBar(
              context,
              state.message,
            );
          } else if (state is TagSubmissionSessionExpired) {
            TokenStorage.clearAll();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
              (route) => false,
            );
          } else if (state is TagSubmissionError) {
            SnackBars.showErrorSnackBar(
              context,
              TextConstants.tagSubmissionError,
            );
          }
        },
        child: widget.showParkFlow ? _buildVehicleDetailsScreen() : _buildFirstScreen(),
      ),
    );
  }
}
