import 'package:vibration/vibration.dart';

/// Manages the continuous alert vibration for retrieval request notifications.
///
/// Using a static flag ensures we never double-start or double-cancel
/// regardless of whether the trigger comes from the notification service
/// (immediate, when the push arrives) or from the UI widget (fallback,
/// when the session sheet becomes visible).
class VibrationController {
  static bool _active = false;

  /// Start a repeating vibration pattern: 700 ms on / 500 ms off.
  /// Idempotent — calling while already active is a no-op.
  static void startRetrievalAlert() {
    if (_active) return;
    _active = true;
    Vibration.vibrate(pattern: [0, 700, 500, 700], repeat: 0);
  }

  /// Cancel any ongoing vibration.
  /// Idempotent — calling while not active is a no-op.
  static void stop() {
    if (!_active) return;
    _active = false;
    Vibration.cancel();
  }
}
