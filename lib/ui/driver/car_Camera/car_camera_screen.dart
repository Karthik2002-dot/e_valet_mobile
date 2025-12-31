import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/driver/preview_car/preview_Car_Screen.dart';
import 'package:niloufer_valet_mobile/bloc/driver/car_camera/car_Camer_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/car_camera/car_camera_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/car_camera/car_Camera_State.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_Camer_widgets/camera_preview_widget.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_Camer_widgets/camera_top_overlay.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_Camer_widgets/camera_bottom_overlay.dart';

class CarCameraScreen extends StatefulWidget {
  final String? sessionId;

  const CarCameraScreen({
    super.key,
    this.sessionId,
  });

  @override
  State<CarCameraScreen> createState() => _CarCameraScreenState();
}

class _CarCameraScreenState extends State<CarCameraScreen>
    with WidgetsBindingObserver, RouteAware {
  late CarCameraBloc _cameraBloc;
  bool _isInitializing = false;
  RouteObserver<ModalRoute>? _routeObserver;

  @override
  void initState() {
    super.initState();
    _cameraBloc = CarCameraBloc();
    _routeObserver = RouteObserver<ModalRoute>();
    WidgetsBinding.instance.addObserver(this);
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
    super.dispose();
  }

  void _initializeCamera({bool force = false}) {
    if (_isInitializing && !force)
      return; // Prevent multiple calls unless forced

    _isInitializing = true;
    if (force) {
      // Force reinitialization by disposing existing controller first
      _cameraBloc.add(const ForceReinitializeCameraRequested());
    } else {
      _cameraBloc.add(const InitializeCameraRequested());
    }

    // Reset flag after a delay to allow for potential reinitialization
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        _isInitializing = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
                ),
              ),
            );
          } else if (state is CarCameraValidationError) {
            // Show error message at bottom of screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(
                  bottom: screenHeight * 0.15,
                  left: screenWidth * 0.05,
                  right: screenWidth * 0.05,
                ),
              ),
            );
            // Reset validation state so user can try again
            context.read<CarCameraBloc>().add(const ValidationReset());
          } else if (state is CarCameraInitializationError) {
            // Show camera initialization error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
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
              backgroundColor: Colors.black,
              appBar: const CustomAppBar(),
              body: Stack(
                children: [
                  // Camera Preview Widget
                  CameraPreviewWidget(
                    isCameraInitialized: isCameraInitialized,
                    cameraController: cameraController,
                  ),

                  // Top Overlay (Flash button, Instructions)
                  CameraTopOverlay(
                    isFlashOn: isFlashOn,
                    onFlashToggle: () => context
                        .read<CarCameraBloc>()
                        .add(const ToggleFlashRequested()),
                  ),

                  // Bottom Overlay (Photo button and text)
                  CameraBottomOverlay(
                    onCapture: _capturePhoto,
                  ),
                ],
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
      ScaffoldMessenger.of(blocContext).showSnackBar(
        const SnackBar(
          content: Text(TextConstants.cameraNotReady),
          backgroundColor: AppColors.error,
        ),
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
        ScaffoldMessenger.of(blocContext).showSnackBar(
          SnackBar(
            content: Text('${TextConstants.errorCapturingPhoto}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
