import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/driver/preview_car/preview_Car_Screen.dart';
import 'package:niloufer_valet_mobile/bloc/driver/car_camera/car_Camer_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/car_camera/car_camera_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/car_camera/car_Camera_State.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_Camer_widgets/camera_preview_widget.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_Camer_widgets/camera_top_overlay.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_Camer_widgets/camera_bottom_overlay.dart';

class CarCameraScreen extends StatefulWidget {
  final String? sessionId;
  final bool isReparking;

  const CarCameraScreen({
    super.key,
    this.sessionId,
    this.isReparking = false,
  });

  @override
  State<CarCameraScreen> createState() => _CarCameraScreenState();
}

class _CarCameraScreenState extends State<CarCameraScreen>
    with WidgetsBindingObserver, RouteAware {
  late CarCameraBloc _cameraBloc;
  bool _isInitializing = false;
  RouteObserver<ModalRoute>? _routeObserver;
  Orientation? _currentOrientation;

  @override
  void initState() {
    super.initState();
    _cameraBloc = CarCameraBloc();
    _routeObserver = RouteObserver<ModalRoute>();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addObserver(this);
    // Set preferred orientations to allow landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver?.subscribe(this, ModalRoute.of(context)!);
    // Only initialize if not already initializing
    if (!_isInitializing) {
      _initializeCamera();
    }
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // Force reinitialize when returning to this screen
    _initializeCamera(force: true);
  }

  @override
  void didUpdateWidget(covariant CarCameraScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Force reinitialize when widget is updated
    if (!_isInitializing) {
      _initializeCamera();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isInitializing) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _cameraBloc.dispose();
    // Reset preferred orientations when leaving camera screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Handle orientation changes
    final orientation = MediaQuery.of(context).orientation;
    if (_currentOrientation != orientation) {
      _currentOrientation = orientation;
      // Reinitialize camera when orientation changes
      if (!_isInitializing) {
        _initializeCamera(force: true);
      }
    }
  }

  void _initializeCamera({bool force = false}) {
    // Prevent multiple simultaneous initializations, even for force requests
    if (_isInitializing) return;

    _isInitializing = true;
    if (force) {
      // Force reinitialization by disposing existing controller first
      _cameraBloc.add(const ForceReinitializeCameraRequested());
    } else {
      _cameraBloc.add(const InitializeCameraRequested());
    }

    // Reset flag after a shorter delay to allow for proper reinitialization
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _isInitializing = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions and orientation for potential future use
    // final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth = MediaQuery.of(context).size.width;
    // final orientation = MediaQuery.of(context).orientation;

    return BlocProvider<CarCameraBloc>.value(
      value: _cameraBloc,
      child: BlocListener<CarCameraBloc, CarCameraState>(
        listener: (context, state) {
          if (state is CarCameraValidationSuccess) {
            // Navigate to preview screen on successful validation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreviewCarScreen(
                  imagePath: state.imagePath,
                  sessionId: widget.sessionId,
                  isReparking: widget.isReparking,
                ),
              ),
            );
          } else if (state is CarCameraValidationError) {
            // Show error message at bottom of screen
            SnackBars.showErrorSnackBar(
              context,
              state.message,
            );
            // Reset validation state so user can try again
            context.read<CarCameraBloc>().add(const ValidationReset());
          } else if (state is CarCameraInitializationError) {
            // Show camera initialization error
            SnackBars.showErrorSnackBar(
              context,
              state.message,
            );
          } else if (state is CarCameraInitial) {
            // Reset initialization flag when state is reset
            _isInitializing = false;
          }
        },
        child: BlocBuilder<CarCameraBloc, CarCameraState>(
          builder: (context, state) {
            final isCameraInitialized = state is CarCameraInitialized ||
                state is CarCameraValidationError ||
                state is CarCameraFlashToggled;
            final cameraController = state is CarCameraInitialized
                ? state.cameraController
                : state is CarCameraValidationError
                    ? state.cameraController
                    : state is CarCameraFlashToggled
                        ? state.cameraController
                        : null;
            final isFlashOn = state is CarCameraInitialized
                ? state.isFlashOn
                : state is CarCameraValidationError
                    ? state.isFlashOn
                    : state is CarCameraFlashToggled
                        ? state.isFlashOn
                        : false;

            return Scaffold(
              backgroundColor: AppColors.black,
              appBar: const CustomAppBar(),
              body: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate approximate input container height based on its content
                  final screenHeight = MediaQuery.of(context).size.height;
                  // Container padding (vertical): 0.015 * 2 = 0.03
                  // Header text: ~0.04, Spacing: 0.008, Input field: 0.06, Spacing: 0.01, Button: 0.035
                  // Total: ~0.183 or 18.3%, using 19% for better alignment
                  final estimatedInputHeight = screenHeight * 0.19;
                  
                  return Stack(
                    children: [
                      // Camera Preview Widget (positioned at bottom)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        top: estimatedInputHeight, // Start right after input container
                        child: CameraPreviewWidget(
                          isCameraInitialized: isCameraInitialized,
                          cameraController: cameraController,
                        ),
                      ),

                      // Top Overlay (Flash button, Instructions) - positioned over camera
                      CameraTopOverlay(
                        isFlashOn: isFlashOn,
                        onFlashToggle: () => context
                            .read<CarCameraBloc>()
                            .add(const ToggleFlashRequested()),
                        topOffset: estimatedInputHeight, // Start at camera area
                      ),

                      // Capture Button Overlay (positioned over camera)
                      Positioned(
                        bottom: MediaQuery.of(context).size.width * 0.1, // Position at bottom with some margin
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Builder(
                            builder: (builderContext) => GestureDetector(
                              onTap: () {
                                _capturePhoto(builderContext);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.18,
                                height: MediaQuery.of(context).size.width * 0.18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Top Overlay (Input field only)
                      CameraBottomOverlay(
                        onCapture: _capturePhoto,
                        onSubmit: _handleSubmitWithParkingLocation,
                        positionAtTop: true,
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _capturePhoto(BuildContext blocContext) async {
    final state = blocContext.read<CarCameraBloc>().state;
    if (state is! CarCameraInitialized && state is! CarCameraFlashToggled) {
      SnackBars.showErrorSnackBar(
        blocContext,
        TextConstants.cameraNotReady,
      );
      return;
    }

    try {
      final cameraController = state is CarCameraInitialized
          ? state.cameraController
          : (state as CarCameraFlashToggled).cameraController;
      final isFlashOn = state is CarCameraInitialized
          ? state.isFlashOn
          : (state as CarCameraFlashToggled).isFlashOn;

      // Ensure the camera is initialized
      // The camera is already initialized when we reach this state

      // Set flash mode for the photo capture
      await cameraController.setFlashMode(
        isFlashOn ? FlashMode.always : FlashMode.off,
      );

      // Take the picture
      final image = await cameraController.takePicture();

      // Restore flash mode for preview (torch for continuous flash, off for no flash)
      await cameraController.setFlashMode(
        isFlashOn ? FlashMode.torch : FlashMode.off,
      );

      // Reset camera state before navigating
      blocContext.read<CarCameraBloc>().add(const ValidationReset());

      // Trigger validation in background
      if (mounted) {
        blocContext.read<CarCameraBloc>().add(
              ValidateImageRequested(image.path),
            );
      }
    } catch (e) {
      if (mounted) {
        SnackBars.showErrorSnackBar(
          blocContext,
          '${TextConstants.errorCapturingPhoto}: $e',
        );
      }
    }
  }

  Future<void> _handleSubmitWithParkingLocation(
    BuildContext context,
    String parkingLocation,
  ) async {
    final state = context.read<CarCameraBloc>().state;
    if (state is! CarCameraInitialized && state is! CarCameraFlashToggled) {
      SnackBars.showErrorSnackBar(
        context,
        TextConstants.cameraNotReady,
      );
      return;
    }

    try {
      final cameraController = state is CarCameraInitialized
          ? state.cameraController
          : (state as CarCameraFlashToggled).cameraController;
      final isFlashOn = state is CarCameraInitialized
          ? state.isFlashOn
          : (state as CarCameraFlashToggled).isFlashOn;

      // Set flash mode for the photo capture
      await cameraController.setFlashMode(
        isFlashOn ? FlashMode.always : FlashMode.off,
      );

      // Take the picture
      final image = await cameraController.takePicture();

      // Restore flash mode for preview
      await cameraController.setFlashMode(
        isFlashOn ? FlashMode.torch : FlashMode.off,
      );

      // Navigate directly to preview screen with parking location
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewCarScreen(
              imagePath: image.path,
              sessionId: widget.sessionId,
              isReparking: widget.isReparking,
              parkingLocation: parkingLocation,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBars.showErrorSnackBar(
          context,
          '${TextConstants.errorCapturingPhoto}: $e',
        );
      }
    }
  }
}
