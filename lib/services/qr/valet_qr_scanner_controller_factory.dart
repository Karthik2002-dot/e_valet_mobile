import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Prefer a full-HD preview on Android — the plugin defaults to 640×480 there,
/// which makes dense valet-card QRs hard to decode quickly.
Size? _valetQrCameraResolution() {
  if (kIsWeb) return null;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return const Size(1920, 1080);
    default:
      return null;
  }
}

/// Shared settings for driver + operator WhatsApp / valet QR flows.
MobileScannerController createValetQrScannerController({
  required bool autoStart,
  bool torchEnabled = false,
}) {
  return MobileScannerController(
    autoStart: autoStart,
    cameraResolution: _valetQrCameraResolution(),
    // Prefer fastest repeat analysis until a decode succeeds; [QrBloc] /
    // [ScannerQrBloc] ignore further reads while processing.
    detectionSpeed: DetectionSpeed.unrestricted,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
    torchEnabled: torchEnabled,
  );
}
