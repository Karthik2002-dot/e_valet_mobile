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

class _QrReaderWidgetState extends State<QrReaderWidget>
    with WidgetsBindingObserver {
  MobileScannerController? controller;
  bool _needsReinitialization = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
  }

  @override
  void activate() {
    super.activate();
    // Widget was reactivated (came back from another route)
    // Reinitialize the controller
    if (_needsReinitialization || controller == null) {
      _initializeController();
    } else {
      // Just restart the existing controller
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && controller != null) {
          try {
            controller!.start();
          } catch (e) {
            // If start fails, reinitialize
            _initializeController();
          }
        }
      });
    }
  }

  @override
  void deactivate() {
    // Widget is being deactivated (navigating away)
    controller?.stop();
    _needsReinitialization = true;
    super.deactivate();
  }

  void _initializeController() {
    // Dispose existing controller if any
    controller?.dispose();

    // Create new controller
    controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode], // QR only
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      autoStart: false, // Manual start for better control
    );

    // Start the controller
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && controller != null) {
        controller!.start();
      }
    });

    _needsReinitialization = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      // Mark for reinitialization and rebuild
      setState(() {
        _needsReinitialization = true;
      });
      _initializeController();
    } else if (state == AppLifecycleState.paused) {
      // Stop controller when app goes to background
      controller?.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  void _handleStateChange(BuildContext context, QrState state) async {
    if (controller == null) return;

    try {
      if (state.isProcessing || state.shouldStopScanner) {
        await controller!.stop();
      } else {
        // Ensure controller is started when not processing
        await controller!.start();
      }
    } catch (e) {
      // If start/stop fails, reinitialize controller
      if (mounted) {
        setState(() {
          _needsReinitialization = true;
        });
        _initializeController();
      }
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

                // Show loading if controller is not initialized
                if (controller == null) {
                  return Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    MobileScanner(
                      controller: controller!,
                      errorBuilder: (context, error, child) {
                        // If there's an error, try to restart the controller
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            setState(() {
                              _needsReinitialization = true;
                            });
                            _initializeController();
                          }
                        });
                        return Container(
                          color: Colors.black,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Camera error. Reinitializing...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: widget.screenWidth * 0.04,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
