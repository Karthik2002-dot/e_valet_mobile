import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum DevicePlatform {
  ANDROID,
  IOS,
  WEB,
}

class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  /// Get the platform name in uppercase format (ANDROID, IOS, WEB)
  static Future<String> getPlatform() async {
    try {
      if (Platform.isAndroid) {
        return DevicePlatform.ANDROID.name;
      } else if (Platform.isIOS) {
        return DevicePlatform.IOS.name;
      } else {
        return DevicePlatform.WEB.name;
      }
    } catch (e) {
      log('Error getting platform: $e');
      return DevicePlatform.ANDROID.name; // Default fallback
    }
  }

  /// Get the device ID (unique identifier)
  static Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // Use Android ID as device identifier
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        // Use identifierForVendor as device identifier
        return iosInfo.identifierForVendor ?? 'unknown-ios-device';
      }
      return 'unknown-device';
    } catch (e) {
      log('Error getting device ID: $e');
      return 'unknown-device';
    }
  }

  /// Get the OS version
  static Future<String> getOsVersion() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return 'iOS ${iosInfo.systemVersion}';
      }
      return 'Unknown OS';
    } catch (e) {
      log('Error getting OS version: $e');
      return 'Unknown OS';
    }
  }

  /// Get the app version
  static Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      log('Error getting app version: $e');
      return 'Unknown Version';
    }
  }

  /// Get device model name
  static Future<String> getDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.model;
      }
      return 'Unknown Device';
    } catch (e) {
      log('Error getting device model: $e');
      return 'Unknown Device';
    }
  }

  /// Get all device information at once
  static Future<Map<String, String>> getAllDeviceInfo() async {
    try {
      final platform = await getPlatform();
      final deviceId = await getDeviceId();
      final osVersion = await getOsVersion();
      final appVersion = await getAppVersion();
      final deviceModel = await getDeviceModel();

      return {
        'platform': platform,
        'deviceId': deviceId,
        'osVersion': osVersion,
        'appVersion': appVersion,
        'deviceModel': deviceModel,
      };
    } catch (e) {
      log('Error getting device info: $e');
      return {
        'platform': 'ANDROID',
        'deviceId': 'unknown-device',
        'osVersion': 'Unknown OS',
        'appVersion': 'Unknown Version',
        'deviceModel': 'Unknown Device',
      };
    }
  }
}
