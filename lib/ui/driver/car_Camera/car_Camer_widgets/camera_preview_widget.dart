import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';

class CameraPreviewWidget extends StatelessWidget {
  final bool isCameraInitialized;
  final CameraController? cameraController;

  const CameraPreviewWidget({
    super.key,
    required this.isCameraInitialized,
    required this.cameraController,
  });

  @override
  Widget build(BuildContext context) {
    if (isCameraInitialized && cameraController != null) {
      final size = MediaQuery.of(context).size;
      final orientation = MediaQuery.of(context).orientation;

      // Calculate aspect ratio based on orientation
      double aspectRatio;
      if (orientation == Orientation.portrait) {
        aspectRatio = size.width / size.height;
      } else {
        aspectRatio = size.height / size.width;
      }

      // Reduce camera height to leave space for parking location input at bottom
      final cameraHeight = size.height * 0.7; // Use 70% of screen height

      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: cameraHeight,
        child: SizedBox(
          width: double.infinity,
          height: cameraHeight,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: CameraPreview(cameraController!),
          ),
        ),
      );
    } else {
      final cameraHeight = MediaQuery.of(context).size.height * 0.7;
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: cameraHeight,
        child: Container(
          width: double.infinity,
          height: cameraHeight,
          color: AppColors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }
  }
}
