import 'package:hive_flutter/hive_flutter.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class SessionManager {
  SessionManager._();

  static const String _loginDateKey = 'session_login_date_v1';
  static const String _isLoggedInKey = 'session_is_logged_in_v1';
  static const String _hasShownScannerIntroKey =
      'session_has_shown_scanner_intro_v1';
  static const String _hasShownCarPhotoIntroKey =
      'session_has_shown_car_photo_intro_v1';

  static Box get _box {
    if (!Hive.isBoxOpen(TokenStorage.boxName)) {
      throw StateError(
        'TokenStorage box not opened. Call TokenStorage.init() first.',
      );
    }
    return Hive.box(TokenStorage.boxName);
  }

  /// Marks the current session as active for today's date.
  static Future<void> markLoggedInForToday() async {
    await _box.put(_isLoggedInKey, true);
    await _box.put(_loginDateKey, _todayKey());
  }

  /// Clears any persisted session metadata (including intro animation flags).
  /// Called on logout so that after the next login, the Camera and Scanner
  /// intro animations (Lottie) are shown once again.
  static Future<void> clearSessionFlags() async {
    await _box.delete(_isLoggedInKey);
    await _box.delete(_loginDateKey);
    await _box.delete(_hasShownScannerIntroKey);
    await _box.delete(_hasShownCarPhotoIntroKey);
  }

  /// True if the QR/scanner intro animation has been shown this login session.
  static Future<bool> hasShownScannerIntroThisSession() async {
    return (_box.get(_hasShownScannerIntroKey) as bool?) ?? false;
  }

  /// Mark that the scanner intro has been shown (so we skip it on retake/return).
  static Future<void> markScannerIntroShown() async {
    await _box.put(_hasShownScannerIntroKey, true);
  }

  /// True if the car photo intro animation has been shown this login session.
  static Future<bool> hasShownCarPhotoIntroThisSession() async {
    return (_box.get(_hasShownCarPhotoIntroKey) as bool?) ?? false;
  }

  /// Mark that the car photo intro has been shown (so we skip it on retake).
  static Future<void> markCarPhotoIntroShown() async {
    await _box.put(_hasShownCarPhotoIntroKey, true);
  }

  /// Returns true when the stored login markers are still valid for today.
  static Future<bool> hasValidSessionForToday() async {
    final isLoggedIn = (_box.get(_isLoggedInKey) as bool?) ?? false;
    if (!isLoggedIn) return false;

    final storedDate = _box.get(_loginDateKey) as String?;
    if (storedDate == null || storedDate.isEmpty) return false;
    if (storedDate != _todayKey()) return false;

    final token = await TokenStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Returns true if user has valid tokens (persistent login check).
  /// This checks for tokens regardless of date, for persistent authentication.
  static Future<bool> isUserLoggedIn() async {
    return await TokenStorage.hasValidTokens();
  }

  static String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}
