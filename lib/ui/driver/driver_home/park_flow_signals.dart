/// Tracks when [CarPhotoIntroScreen] (park / camera flow) is on the stack so
/// retrieval "Collect Keys" can defer the accept API and Confirm Arrival.
class ParkFlowSignals {
  ParkFlowSignals._();

  static int _carPhotoDepth = 0;

  static bool get isCarPhotoParkFlowActive => _carPhotoDepth > 0;

  static void beginCarPhotoParkFlow() {
    _carPhotoDepth++;
  }

  static void endCarPhotoParkFlow() {
    if (_carPhotoDepth > 0) _carPhotoDepth--;
  }
}
