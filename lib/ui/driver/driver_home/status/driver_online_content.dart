import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/tag_submission/tag_submission_state.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/driver_qr_scanner_content.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/driver_manual_entry_content.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/oauth/login/login.dart';

class DriverOnlineContent extends StatefulWidget {
  final String driverName;
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;

  const DriverOnlineContent({
    super.key,
    required this.driverName,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  State<DriverOnlineContent> createState() => _DriverOnlineContentState();
}

class _DriverOnlineContentState extends State<DriverOnlineContent> {
  bool _isManualEntry = false;

  void _toggleEntryMode(BuildContext context) {
    setState(() {
      _isManualEntry = !_isManualEntry;
    });
    // Reset tag submission state when switching modes
    context.read<TagSubmissionBloc>().add(const TagSubmissionReset());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TagSubmissionBloc(),
      child: BlocListener<TagSubmissionBloc, TagSubmissionState>(
        listener: (context, state) {
          if (state is TagSubmissionSuccess) {
            // TODO: Handle success (e.g., show snackbar, navigate, etc.)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is TagSubmissionSessionExpired) {
            // Clear tokens and navigate to login
            TokenStorage.clearAll();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
              (route) => false,
            );
          } else if (state is TagSubmissionError) {
            // TODO: Handle error (e.g., show error dialog)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Column(
          children: [
            SizedBox(height: widget.screenHeight * 0.03),
            // Welcome message
            TextComponent(
              labelText: TextConstants.readyToParkMessage(widget.driverName),
              fontSize: widget.isDesktop
                  ? widget.screenWidth * 0.018
                  : widget.isTablet
                      ? widget.screenWidth * 0.028
                      : widget.screenWidth * 0.05,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: widget.screenHeight * 0.01),
            TextComponent(
              labelText: _isManualEntry
                  ? TextConstants.enterTagNumberTitle
                  : TextConstants.scanKeyTagInstruction,
              fontSize: widget.isDesktop
                  ? widget.screenWidth * 0.012
                  : widget.isTablet
                      ? widget.screenWidth * 0.02
                      : widget.screenWidth * 0.035,
              fontWeight: FontWeight.w400,
              color: AppColors.black,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: widget.screenHeight * 0.03),
            // Conditional content: QR Scanner or Manual Entry
            Builder(
              builder: (context) {
                if (_isManualEntry) {
                  return DriverManualEntryContent(
                    screenWidth: widget.screenWidth,
                    screenHeight: widget.screenHeight,
                    isTablet: widget.isTablet,
                    isDesktop: widget.isDesktop,
                    onSwitchToQrScanner: () => _toggleEntryMode(context),
                  );
                } else {
                  return DriverQrScannerContent(
                    screenWidth: widget.screenWidth,
                    screenHeight: widget.screenHeight,
                    isTablet: widget.isTablet,
                    isDesktop: widget.isDesktop,
                    onSwitchToManualEntry: () => _toggleEntryMode(context),
                  );
                }
              },
            ),
            SizedBox(height: widget.screenHeight * 0.03),
          ],
        ),
      ),
    );
  }
}
