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
    with WidgetsBindingObserver, RouteAware {
  MobileScannerController? controller;
  bool _isInitializing = false;
  RouteObserver<ModalRoute>? _routeObserver;

  @override
  void initState() {
    super.initState();
    _routeObserver = RouteObserver<ModalRoute>();
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver?.subscribe(this, ModalRoute.of(context)!);
    // Always try to ensure camera is ready when dependencies change
    _ensureCameraReady();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // Force reinitialize when returning to this screen
    _ensureCameraReady();
  }

  @override
  void didUpdateWidget(covariant QrReaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ensure camera is ready when widget is updated
    _ensureCameraReady();
  }

  @override
  void activate() {
    super.activate();
    // Widget was reactivated (came back from another route)
    // Always ensure camera is ready
    _ensureCameraReady();
  }

  @override
  void deactivate() {
    // Widget is being deactivated (navigating away)
    controller?.stop();
    super.deactivate();
  }

  void _ensureCameraReady() {
    // Always try to ensure camera is ready, regardless of current state
    if (!mounted) return;

    // If already initializing, don't start another initialization
    if (_isInitializing) return;

    _isInitializing = true;

    try {
      if (controller == null) {
        // No controller exists, create one
        _initializeController();
      } else {
        // Controller exists, try to start it
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
    } finally {
      // Reset flag after a reasonable delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _isInitializing = false;
        }
      });
    }
  }

  void _initializeController({bool force = false}) {
    // Prevent multiple simultaneous initializations
    if (_isInitializing && !force) return;

    _isInitializing = true;

    try {
      // Dispose existing controller if any (always dispose on force, or if controller is null)
      if (force || controller == null) {
        controller?.dispose();
        controller = null;

        // Create new controller
        controller = MobileScannerController(
          formats: const [BarcodeFormat.qrCode], // QR only
          detectionSpeed: DetectionSpeed.noDuplicates,
          facing: CameraFacing.back,
          autoStart: false, // Manual start for better control
        );

        // Start the controller with retry mechanism
        _startControllerWithRetry();
      }
    } finally {
      // Reset flag after a reasonable delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _isInitializing = false;
        }
      });
    }
  }

  void _startControllerWithRetry() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted || controller == null) return;

      try {
        controller!.start();
      } catch (e) {
        // Retry after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && controller != null) {
            try {
              controller!.start();
            } catch (e2) {
              // If still failing, reinitialize
              if (mounted) {
                _initializeController(force: true);
              }
            }
          }
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      // Always ensure camera is ready when app resumes
      _ensureCameraReady();
    } else if (state == AppLifecycleState.paused) {
      // Stop controller when app goes to background
      controller?.stop();
    } else if (state == AppLifecycleState.inactive) {
      // Stop controller when app becomes inactive
      controller?.stop();
    }
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
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
      // If start/stop fails, ensure camera is ready
      if (mounted) {
        _ensureCameraReady();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure camera is ready when building the widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _ensureCameraReady();
      }
    });

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
                        // If there's an error, ensure camera is ready
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            _ensureCameraReady();
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
