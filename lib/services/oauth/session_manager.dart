import 'package:hive_flutter/hive_flutter.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

class SessionManager {
  SessionManager._();

  static const String _loginDateKey = 'session_login_date_v1';
  static const String _isLoggedInKey = 'session_is_logged_in_v1';

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

  /// Clears any persisted session metadata.
  static Future<void> clearSessionFlags() async {
    await _box.delete(_isLoggedInKey);
    await _box.delete(_loginDateKey);
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

  static String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}
