import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Service for reading notification text aloud with loud, hearable audio.
/// Used when push notifications are received so the body is spoken clearly.
class TextToSpeechService {
  static final TextToSpeechService _instance =
      TextToSpeechService._internal();
  factory TextToSpeechService() => _instance;
  TextToSpeechService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  /// Initialize TTS with maximum volume and speaker output for hearable playback.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Maximum volume (1.0 = loudest) for hearable audio
      await _flutterTts.setVolume(1.0);
      // Slightly slower rate for clarity (0.4–0.5 is clear; 0.0 = slowest)
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setPitch(1.0);

      // On iOS, route audio to speaker (not earpiece) so it's loud and hearable
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          ],
        );
      }

      _isInitialized = true;
      log('TextToSpeechService initialized (volume: max, speaker output)');
    } catch (e) {
      log('Error initializing TextToSpeechService: $e');
    }
  }

  /// Speak the given text aloud with loud, hearable audio.
  /// Use for notification body (e.g. "Card #22 - Yathi Solutions").
  /// [text] – message to speak; if null/empty, nothing is spoken.
  Future<void> speak(String? text) async {
    final trimmed = text?.trim();
    if (trimmed == null || trimmed.isEmpty) return;

    try {
      if (!_isInitialized) await initialize();

      await _flutterTts.setVolume(1.0);
      await _flutterTts.speak(trimmed);
      log('TTS speaking: $trimmed');
    } catch (e) {
      log('Error in TTS speak: $e');
    }
  }

  /// Stop any ongoing speech.
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      log('Error stopping TTS: $e');
    }
  }
}
