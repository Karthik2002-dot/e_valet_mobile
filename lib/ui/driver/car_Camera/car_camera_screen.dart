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
  const CarCameraScreen({super.key});

  @override
  State<CarCameraScreen> createState() => _CarCameraScreenState();
}

class _CarCameraScreenState extends State<CarCameraScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize camera through BLoC
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarCameraBloc>().add(const InitializeCameraRequested());
    });
  }

  @override
  void dispose() {
    context.read<CarCameraBloc>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (context) => CarCameraBloc(),
      child: BlocListener<CarCameraBloc, CarCameraState>(
        listener: (context, state) {
          if (state is CarCameraValidationSuccess) {
            // Navigate to preview screen on successful validation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreviewCarScreen(
                  imagePath: state.imagePath,
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
          }
        },
        child: BlocBuilder<CarCameraBloc, CarCameraState>(
          builder: (context, state) {
            final isCameraInitialized = state is CarCameraInitialized;
            final cameraController =
                state is CarCameraInitialized ? state.cameraController : null;
            final isFlashOn = state is CarCameraInitialized
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

                  // Top Overlay (Back button, Flash button, Instructions)
                  CameraTopOverlay(
                    isFlashOn: isFlashOn,
                    onFlashToggle: () => context
                        .read<CarCameraBloc>()
                        .add(const ToggleFlashRequested()),
                    onBack: () => Navigator.pop(context),
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
    if (state is! CarCameraInitialized) {
      ScaffoldMessenger.of(blocContext).showSnackBar(
        const SnackBar(
          content: Text(TextConstants.cameraNotReady),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final cameraController = state.cameraController;
      final isFlashOn = state.isFlashOn;

      // Ensure the camera is initialized
      // The camera is already initialized when we reach this state

      // Turn off flash if it's on
      if (isFlashOn) {
        await cameraController.setFlashMode(FlashMode.off);
      }

      // Set flash mode for the photo
      await cameraController.setFlashMode(
        isFlashOn ? FlashMode.always : FlashMode.off,
      );

      // Take the picture
      final image = await cameraController.takePicture();

      // Restore flash mode if it was on
      if (isFlashOn) {
        await cameraController.setFlashMode(FlashMode.torch);
      }

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
