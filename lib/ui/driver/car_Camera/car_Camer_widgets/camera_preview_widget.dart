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
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: CameraPreview(cameraController!),
      );
    } else {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }
  }
}

