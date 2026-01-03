import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_event.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
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
  bool _initialCameraCheckDone = false;
  RouteObserver<ModalRoute>? _routeObserver;

  @override
  void initState() {
    super.initState();
    _routeObserver = RouteObserver<ModalRoute>();
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
  }

  void _checkAndStartCameraForInitialState() {
    // This is called after widget is built to ensure camera starts for initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Get current QR state from BLoC
      final qrBloc = context.read<QrBloc>();
      final currentState = qrBloc.state;

      // Use BLoC's decision on whether camera should be active
      if (currentState.cameraShouldBeActive && !_isInitializing) {
        _ensureCameraReady(currentState);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver?.subscribe(this, ModalRoute.of(context)!);
    // Only ensure camera if widget is becoming visible and no QR data exists
    // We'll let the state change handler manage this instead
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // When returning to screen, let state change handler manage camera
    // Don't force camera start here as it might conflict with existing data
  }

  @override
  void didUpdateWidget(covariant QrReaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget updated, let state change handler manage camera state
  }

  @override
  void activate() {
    super.activate();
    // Widget reactivated, let state change handler manage camera based on current state
  }

  @override
  void deactivate() {
    // Widget is being deactivated (navigating away)
    controller?.stop();
    super.deactivate();
  }

  void _ensureCameraReady([QrState? state]) {
    // Only ensure camera is ready if BLoC says camera should be active
    if (!mounted) return;

    // If we have state info, check if camera should be active according to BLoC
    if (state != null && !state.cameraShouldBeActive) return;

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

        // Check current state and start controller if needed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final qrBloc = context.read<QrBloc>();
            final currentState = qrBloc.state;

            // Use BLoC's decision on whether camera should be active
            if (currentState.cameraShouldBeActive) {
              _startControllerWithRetry();
            }
          }
        });
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
      // When app resumes, check current state and start camera if needed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final qrBloc = context.read<QrBloc>();
          final currentState = qrBloc.state;

          // Use BLoC's decision on whether camera should be active
          if (currentState.cameraShouldBeActive && !_isInitializing) {
            _ensureCameraReady(currentState);
          }
        }
      });
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
    _initialCameraCheckDone = false; // Reset for next initialization
    super.dispose();
  }

  void _handleStateChange(BuildContext context, QrState state) async {
    if (controller == null) {
      // If no controller but camera should be active, initialize it
      if (state.cameraShouldBeActive) {
        _initializeController();
      }
      return;
    }

    try {
      if (state.cameraShouldBeActive) {
        // Camera should be active according to BLoC state
        await controller!.start();
      } else {
        // Camera should be stopped according to BLoC state
        await controller!.stop();
      }
    } catch (e) {
      // If camera operation fails, try to recover based on current state
      if (mounted) {
        _handleCameraError(state);
      }
    }
  }

  void _handleCameraError(QrState state) {
    // Only try to restart camera if BLoC says it should be active
    if (state.cameraShouldBeActive) {
      _ensureCameraReady(state);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure initial camera state check is done only once
    if (!_initialCameraCheckDone) {
      _initialCameraCheckDone = true;
      _checkAndStartCameraForInitialState();
    }

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
                    color: AppColors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.white,
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
                          color: AppColors.black,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.white,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                TextComponent(
                                  labelText:
                                      TextConstants.cameraErrorReinitializing,
                                  color: AppColors.white,
                                  fontSize: widget.screenWidth * 0.04,
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
