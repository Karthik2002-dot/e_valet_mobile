import 'package:hive_flutter/hive_flutter.dart';

class TokenStorage {
  static const String _parkingLocationKey = 'parking_location';

  // Parking Location management
  static Future<void> saveParkingLocation(String location) async {
    try {
      await _box.put(_parkingLocationKey, location);
    } catch (e) {
      print('[TokenStorage] ❌ Error saving parking location: $e');
      rethrow;
    }
  }

  static Future<String?> getParkingLocation() async {
    try {
      return _box.get(_parkingLocationKey) as String?;
    } catch (e) {
      print('[TokenStorage] ❌ Error retrieving parking location: $e');
      return null;
    }
  }

  static Future<void> clearParkingLocation() async {
    try {
      await _box.delete(_parkingLocationKey);
    } catch (e) {
      print('[TokenStorage] ❌ Error clearing parking location: $e');
    }
  }

  static const String _boxName = 'authBox';

  // Public getter so other classes can reuse the same box name
  static String get boxName => _boxName;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _accessTokenExpiryKey = 'access_token_expiry';
  static const String _firstNameKey = 'user_first_name';
  static const String _lastNameKey = 'user_last_name';
  static const String _phoneNumberKey = 'user_phone_number';
  static const String _resetTokenKey = 'reset_token';
  static const String _sessionIdKey = 'session_id';
  static const String _pendingPhotoKey = 'pending_photo_path';
  static const String _sessionIdFromGetApiKey = 'session_id_from_get_api';
  static const String _assignedSessionDataKey = 'assigned_session_data';
  static const String _arrivalLocationKey = 'arrival_location';
  static const String _arrivalLatitudeKey = 'arrival_latitude';
  static const String _arrivalLongitudeKey = 'arrival_longitude';
  static const String _currentLocationKey = 'current_location';
  static const String _currentLatitudeKey = 'current_latitude';
  static const String _currentLongitudeKey = 'current_longitude';

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

  static Future<void> saveAccessTokenExpiry(DateTime expiry) async {
    try {
      await _box.put(_accessTokenExpiryKey, expiry.toIso8601String());
    } catch (e) {
      print('[TokenStorage] Error saving access token expiry: $e');
      rethrow;
    }
  }

  static Future<DateTime?> getAccessTokenExpiry() async {
    try {
      final expiryStr = _box.get(_accessTokenExpiryKey) as String?;
      if (expiryStr == null) return null;
      return DateTime.parse(expiryStr);
    } catch (e) {
      print('[TokenStorage] Error retrieving access token expiry: $e');
      return null;
    }
  }

  static Future<void> clearAccessToken() async {
    try {
      await _box.delete(_accessTokenKey);
      await _box.delete(_accessTokenExpiryKey);
    } catch (e) {
      print('[TokenStorage] Error clearing access token: $e');
    }
  }

  static Future<bool> isAccessTokenExpiredOrExpiringSoon() async {
    try {
      final expiry = await getAccessTokenExpiry();
      if (expiry == null) return true; // If no expiry, consider expired
      final now = DateTime.now();
      // Consider expired if less than 2 minutes left
      return now.isAfter(expiry.subtract(const Duration(minutes: 2)));
    } catch (e) {
      print('[TokenStorage] Error checking token expiry: $e');
      return true; // On error, assume expired
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
      final sessionId = _box.get(_sessionIdKey) as String?;
      return sessionId;
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

  // Pending photo management
  static Future<void> savePendingPhotoPath(String photoPath) async {
    try {
      await _box.put(_pendingPhotoKey, photoPath);
    } catch (e) {
      print('[TokenStorage] Error saving pending photo path: $e');
      rethrow;
    }
  }

  static Future<String?> getPendingPhotoPath() async {
    try {
      return _box.get(_pendingPhotoKey) as String?;
    } catch (e) {
      print('[TokenStorage] Error retrieving pending photo path: $e');
      return null;
    }
  }

  static Future<void> clearPendingPhotoPath() async {
    try {
      await _box.delete(_pendingPhotoKey);
    } catch (e) {
      print('[TokenStorage] Error clearing pending photo path: $e');
    }
  }

  // Session ID from GET API management
  static Future<void> saveSessionIdFromGetApi(String sessionId) async {
    try {
      await _box.put(_sessionIdFromGetApiKey, sessionId);
    } catch (e) {
      print('[TokenStorage] ❌ Error saving sessionId from GET API: $e');
      rethrow;
    }
  }

  static Future<String?> getSessionIdFromGetApi() async {
    try {
      final sessionId = _box.get(_sessionIdFromGetApiKey) as String?;
      return sessionId;
    } catch (e) {
      print('[TokenStorage] ❌ Error retrieving sessionId from GET API: $e');
      return null;
    }
  }

  static Future<void> clearSessionIdFromGetApi() async {
    try {
      await _box.delete(_sessionIdFromGetApiKey);
    } catch (e) {
      print('[TokenStorage] ❌ Error clearing sessionId from GET API: $e');
    }
  }

  // Assigned Session Data management
  static Future<void> saveAssignedSessionData(
      Map<String, dynamic> sessionData) async {
    try {
      await _box.put(_assignedSessionDataKey, sessionData);
    } catch (e) {
      print('[TokenStorage] ❌ Error saving assigned session data: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getAssignedSessionData() async {
    try {
      final data = _box.get(_assignedSessionDataKey) as Map<String, dynamic>?;
      return data;
    } catch (e) {
      print('[TokenStorage] ❌ Error retrieving assigned session data: $e');
      return null;
    }
  }

  static Future<void> clearAssignedSessionData() async {
    try {
      await _box.delete(_assignedSessionDataKey);
    } catch (e) {
      print('[TokenStorage] ❌ Error clearing assigned session data: $e');
    }
  }

  // Arrival Location management
  static Future<void> saveArrivalLocation({
    required double latitude,
    required double longitude,
    required String location,
  }) async {
    try {
      await _box.put(_arrivalLatitudeKey, latitude);
      await _box.put(_arrivalLongitudeKey, longitude);
      await _box.put(_arrivalLocationKey, location);
    } catch (e) {
      print('[TokenStorage] ❌ Error saving arrival location: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getArrivalLocation() async {
    try {
      final latitude = _box.get(_arrivalLatitudeKey) as double?;
      final longitude = _box.get(_arrivalLongitudeKey) as double?;
      final location = _box.get(_arrivalLocationKey) as String?;

      if (latitude != null && longitude != null && location != null) {
        return {
          'latitude': latitude,
          'longitude': longitude,
          'location': location,
        };
      }
      return null;
    } catch (e) {
      print('[TokenStorage] ❌ Error retrieving arrival location: $e');
      return null;
    }
  }

  static Future<void> clearArrivalLocation() async {
    try {
      await _box.delete(_arrivalLatitudeKey);
      await _box.delete(_arrivalLongitudeKey);
      await _box.delete(_arrivalLocationKey);
    } catch (e) {
      print('[TokenStorage] ❌ Error clearing arrival location: $e');
    }
  }

  // Current Location management (used for accept, arrived, handover APIs)
  static Future<void> saveCurrentLocation({
    required double latitude,
    required double longitude,
    required String location,
  }) async {
    try {
      await _box.put(_currentLatitudeKey, latitude);
      await _box.put(_currentLongitudeKey, longitude);
      await _box.put(_currentLocationKey, location);
    } catch (e) {
      print('[TokenStorage] ❌ Error saving current location: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      final latitude = _box.get(_currentLatitudeKey) as double?;
      final longitude = _box.get(_currentLongitudeKey) as double?;
      final location = _box.get(_currentLocationKey) as String?;

      if (latitude != null && longitude != null && location != null) {
        return {
          'latitude': latitude,
          'longitude': longitude,
          'location': location,
        };
      }
      return null;
    } catch (e) {
      print('[TokenStorage] ❌ Error retrieving current location: $e');
      return null;
    }
  }

  static Future<void> clearCurrentLocation() async {
    try {
      await _box.delete(_currentLatitudeKey);
      await _box.delete(_currentLongitudeKey);
      await _box.delete(_currentLocationKey);
    } catch (e) {
      print('[TokenStorage] ❌ Error clearing current location: $e');
    }
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
