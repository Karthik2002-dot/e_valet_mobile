import 'package:hive_flutter/hive_flutter.dart';

class TokenStorage {
  static const String _boxName = 'authBox';

  // Public getter so other classes can reuse the same box name
  static String get boxName => _boxName;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _firstNameKey = 'user_first_name';
  static const String _lastNameKey = 'user_last_name';
  static const String _phoneNumberKey = 'user_phone_number';
  static const String _resetTokenKey = 'reset_token';
  static const String _sessionIdKey = 'session_id';

  /// Must be called once at app start (after Hive.initFlutter()).
  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  static Box get _box {
    if (!Hive.isBoxOpen(_boxName)) {
      throw StateError(
        'TokenStorage box not opened. Call TokenStorage.init() first.',
      );
    }
    return Hive.box(_boxName);
  }

  // Access token
  static Future<void> saveAccessToken(String token) async {
    try {
      await _box.put(_accessTokenKey, token);
    } catch (e) {
      print('[TokenStorage] Error saving access token: $e');
      rethrow;
    }
  }

  static Future<String?> getAccessToken() async {
    try {
      return _box.get(_accessTokenKey) as String?;
    } catch (e) {
      print('[TokenStorage] Error retrieving access token: $e');
      return null;
    }
  }

  static Future<void> clearAccessToken() async {
    try {
      await _box.delete(_accessTokenKey);
    } catch (e) {
      print('[TokenStorage] Error clearing access token: $e');
    }
  }

  // Refresh token
  static Future<void> saveRefreshToken(String token) async {
    try {
      await _box.put(_refreshTokenKey, token);
    } catch (e) {
      print('[TokenStorage] Error saving refresh token: $e');
      rethrow;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      return _box.get(_refreshTokenKey) as String?;
    } catch (e) {
      print('[TokenStorage] Error retrieving refresh token: $e');
      return null;
    }
  }

  static Future<void> clearRefreshToken() async {
    try {
      await _box.delete(_refreshTokenKey);
    } catch (e) {
      print('[TokenStorage] Error clearing refresh token: $e');
    }
  }

  // User name
  static Future<void> saveUserName({
    required String firstName,
    required String lastName,
  }) async {
    try {
      await _box.put(_firstNameKey, firstName);
      await _box.put(_lastNameKey, lastName);
    } catch (e) {
      print('[TokenStorage] Error saving user name: $e');
      rethrow;
    }
  }

  static Future<String?> getFirstName() async {
    try {
      return _box.get(_firstNameKey) as String?;
    } catch (e) {
      print('[TokenStorage] Error retrieving first name: $e');
      return null;
    }
  }

  static Future<String?> getLastName() async {
    try {
      return _box.get(_lastNameKey) as String?;
    } catch (e) {
      print('[TokenStorage] Error retrieving last name: $e');
      return null;
    }
  }

  static Future<void> clearUserName() async {
    try {
      await _box.delete(_firstNameKey);
      await _box.delete(_lastNameKey);
    } catch (e) {
      print('[TokenStorage] Error clearing user name: $e');
    }
  }

  // Phone number (identifier)
  static Future<void> savePhoneNumber(String phoneNumber) async {
    try {
      await _box.put(_phoneNumberKey, phoneNumber);
    } catch (e) {
      print('[TokenStorage] Error saving phone number: $e');
      rethrow;
    }
  }

  static Future<String?> getPhoneNumber() async {
    try {
      return _box.get(_phoneNumberKey) as String?;
    } catch (e) {
      print('[TokenStorage] Error retrieving phone number: $e');
      return null;
    }
  }

  static Future<void> clearPhoneNumber() async {
    try {
      await _box.delete(_phoneNumberKey);
    } catch (e) {
      print('[TokenStorage] Error clearing phone number: $e');
    }
  }

  // Reset token (password reset flow)
  static Future<void> saveResetToken(String token) async {
    try {
      await _box.put(_resetTokenKey, token);
    } catch (e) {
      print('[TokenStorage] Error saving reset token: $e');
      rethrow;
    }
  }

  static Future<String?> getResetToken() async {
    try {
      return _box.get(_resetTokenKey) as String?;
    } catch (e) {
      print('[TokenStorage] Error retrieving reset token: $e');
      return null;
    }
  }

  static Future<void> clearResetToken() async {
    try {
      await _box.delete(_resetTokenKey);
    } catch (e) {
      print('[TokenStorage] Error clearing reset token: $e');
    }
  }

  // Session ID (for parking session)
  static Future<void> saveSessionId(String sessionId) async {
    try {
      await _box.put(_sessionIdKey, sessionId);
    } catch (e) {
      print('[TokenStorage] Error saving session ID: $e');
      rethrow;
    }
  }

  static Future<String?> getSessionId() async {
    try {
      return _box.get(_sessionIdKey) as String?;
    } catch (e) {
      print('[TokenStorage] Error retrieving session ID: $e');
      return null;
    }
  }

  static Future<void> clearSessionId() async {
    try {
      await _box.delete(_sessionIdKey);
    } catch (e) {
      print('[TokenStorage] Error clearing session ID: $e');
    }
  }

  static Future<bool> hasSessionId() async {
    final sessionId = await getSessionId();
    return sessionId != null && sessionId.isNotEmpty;
  }

  // Bulk helpers
  static Future<void> clearAllTokens() async {
    await clearAccessToken();
    await clearRefreshToken();
  }

  static Future<void> clearAll() async {
    await clearAllTokens();
    await clearUserName();
    await clearPhoneNumber();
    await clearResetToken();
    await clearSessionId();
  }

  static Future<bool> hasValidTokens() async {
    final access = await getAccessToken();
    final refresh = await getRefreshToken();
    return (access != null && access.isNotEmpty) ||
        (refresh != null && refresh.isNotEmpty);
  }
}
