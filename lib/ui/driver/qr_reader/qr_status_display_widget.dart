import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_state.dart';
import 'package:niloufer_valet_mobile/ui/driver/qr_reader/qr_widgets/qr_processing_widget.dart';
import 'package:niloufer_valet_mobile/ui/driver/qr_reader/qr_widgets/qr_success_widget.dart';
import 'package:niloufer_valet_mobile/ui/driver/qr_reader/qr_widgets/qr_error_widget.dart';
import 'package:niloufer_valet_mobile/ui/driver/qr_reader/qr_widgets/qr_scanned_data_widget.dart';

class QrStatusDisplayWidget extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;

  const QrStatusDisplayWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QrBloc, QrState>(
      builder: (context, state) {
        final scanned = state.scannedCode;
        final isProcessing = state.isProcessing;
        final successMsg = state.successMessage;
        final errorMsg = state.errorMessage;

        if (isProcessing && scanned != null) {
          return QrProcessingWidget(
            scanned: scanned,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            isTablet: isTablet,
            isDesktop: isDesktop,
          );
        }

        if (successMsg != null && scanned != null) {
          return QrSuccessWidget(
            successMsg: successMsg,
            scanned: scanned,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            isTablet: isTablet,
            isDesktop: isDesktop,
          );
        }

        if (errorMsg != null && scanned != null) {
          return QrErrorWidget(
            errorMsg: errorMsg,
            scanned: scanned,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            isTablet: isTablet,
            isDesktop: isDesktop,
          );
        }

        if (scanned != null && !isProcessing) {
          return QrScannedDataWidget(
            scanned: scanned,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            isTablet: isTablet,
            isDesktop: isDesktop,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
