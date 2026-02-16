import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_state.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/driver_action_card.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/driver_vehicle_details_screen.dart';
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: h * 0.02),
                  TextComponent(
                    labelText:
                        TextConstants.readyToParkMessage(widget.driverName),
                    fontSize: w * 0.048,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  SizedBox(height: h * 0.025),
                  DriverActionCard(
                    imagePath: 'assets/images/park.png',
                    buttonLabel: TextConstants.parkVehicle,
                    onTap: () => widget.onParkFlowChanged(true),
                    screenWidth: widget.screenWidth,
                    screenHeight: widget.screenHeight,
                    isTablet: widget.isTablet,
                    isDesktop: widget.isDesktop,
                  ),
                  SizedBox(height: h * 0.04),
                  DriverActionCard(
                    imagePath: 'assets/images/retrive.png',
                    buttonLabel: TextConstants.retrieveVehicle,
                    onTap: null,
                    screenWidth: widget.screenWidth,
                    screenHeight: widget.screenHeight,
                    isTablet: widget.isTablet,
                    isDesktop: widget.isDesktop,
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

  Widget _buildVehicleDetailsScreen() {
    return DriverVehicleDetailsScreen(
      screenWidth: widget.screenWidth,
      screenHeight: widget.screenHeight,
      isTablet: widget.isTablet,
      isDesktop: widget.isDesktop,
      onReturnFromCarCamera: () => widget.onParkFlowChanged(false),
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
        child: widget.showParkFlow
            ? _buildVehicleDetailsScreen()
            : _buildFirstScreen(),
      ),
    );
  }
}
