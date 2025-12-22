import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_event.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/driver/qr_reader/qr_status_overlay_widget.dart';
import 'package:niloufer_valet_mobile/ui/driver/qr_reader/scanner_brackets_painter.dart';

class QrReaderWidget extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isDesktop;

  const QrReaderWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  State<QrReaderWidget> createState() => _QrReaderWidgetState();
}

class _QrReaderWidgetState extends State<QrReaderWidget> {
  late MobileScannerController controller;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode], // QR only
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      autoStart: true,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleStateChange(BuildContext context, QrState state) {
    if (state.isProcessing || state.shouldStopScanner) {
      controller.stop();
    } else {
      controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scannerHeight = widget.isDesktop
        ? widget.screenHeight * 0.35
        : widget.isTablet
            ? widget.screenHeight * 0.38
            : widget.screenHeight * 0.35;

    final scannerContentWidth = widget.screenWidth * 0.75;
    final scannerContentHeight = scannerHeight * 0.7;
    final borderWidth = widget.screenWidth * 0.005;
    final borderRadius = widget.screenWidth * 0.03;
    final scannerContainerWidth = widget.screenWidth * 0.85;

    return Center(
      child: Container(
        width: scannerContainerWidth,
        height: scannerHeight,
        decoration: BoxDecoration(
          color: AppColors.lightBeigeBackground,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: borderWidth,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BlocListener<QrBloc, QrState>(
            listener: _handleStateChange,
            child: BlocBuilder<QrBloc, QrState>(
              builder: (context, state) {
                final isProcessing = state.isProcessing;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    MobileScanner(
                      controller: controller,
                      onDetect: (capture) {
                        if (isProcessing || state.shouldStopScanner) return;
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final barcode = barcodes.first;
                          final value = barcode.rawValue;
                          if (value != null && value.isNotEmpty) {
                            context.read<QrBloc>().add(QrCodeDetected(value));
                          }
                        }
                      },
                    ),
                    // Overlay with L-shaped corner brackets
                    CustomPaint(
                      size: Size(scannerContentWidth, scannerContentHeight),
                      painter: ScannerBracketsPainter(
                        strokeWidth: borderWidth * 2,
                        cornerLength: widget.screenWidth * 0.1,
                      ),
                    ),
                    // Scanning lines overlay
                    Container(
                      width: scannerContentWidth,
                      height: scannerContentHeight,
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: AppColors.primary.withOpacity(0.5),
                            width: borderWidth,
                          ),
                        ),
                      ),
                    ),
                    if (isProcessing)
                      Container(
                        color: AppColors.qrProcessingOverlay,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    // Success/Error overlay card on scanner
                    if (state.shouldStopScanner &&
                        (state.qrData != null || state.errorMessage != null))
                      Positioned(
                        top: scannerHeight * 0.2,
                        left: scannerContainerWidth * 0.1,
                        right: scannerContainerWidth * 0.1,
                        child: QrStatusOverlayWidget(
                          state: state,
                          screenWidth: widget.screenWidth,
                          screenHeight: widget.screenHeight,
                          isTablet: widget.isTablet,
                          isDesktop: widget.isDesktop,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
