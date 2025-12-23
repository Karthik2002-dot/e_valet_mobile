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
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  bool _isFlashOn = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(TextConstants.cameraNotAvailable),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Use the back camera
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      _initializeControllerFuture = _cameraController!.initialize();
      await _initializeControllerFuture;

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${TextConstants.errorInitializingCamera}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_isCameraInitialized) return;

    try {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });

      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${TextConstants.errorTogglingFlash}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: const CustomAppBar(),
          body: Stack(
            children: [
              // Camera Preview Widget
              CameraPreviewWidget(
                isCameraInitialized: _isCameraInitialized,
                cameraController: _cameraController,
              ),

              // Top Overlay (Back button, Flash button, Instructions)
              CameraTopOverlay(
                isFlashOn: _isFlashOn,
                onFlashToggle: _toggleFlash,
                onBack: () => Navigator.pop(context),
              ),

              // Bottom Overlay (Photo button and text)
              CameraBottomOverlay(
                onCapture: _capturePhoto,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _capturePhoto(BuildContext blocContext) async {
    if (_cameraController == null || !_isCameraInitialized) {
      ScaffoldMessenger.of(blocContext).showSnackBar(
        const SnackBar(
          content: Text(TextConstants.cameraNotReady),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      // Ensure the camera is initialized
      await _initializeControllerFuture;

      // Turn off flash if it's on
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      }

      // Set flash mode for the photo
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.always : FlashMode.off,
      );

      // Take the picture
      final image = await _cameraController!.takePicture();

      // Restore flash mode if it was on
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.torch);
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

