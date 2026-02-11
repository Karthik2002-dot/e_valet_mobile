import 'package:permission_handler/permission_handler.dart';

/// Result of checking a single permission.
enum PermissionStatusType {
  granted,
  denied,
  permanentlyDenied,
}

/// Service for the three required app permissions: Location, Camera, Notifications.
class PermissionsService {
  PermissionsService._();

  static bool _permissionsCompletedOnce = false;

  /// True after the user has completed the permissions screen at least once (initial flow).
  static bool get permissionsCompletedOnce => _permissionsCompletedOnce;

  /// Call when user taps Continue from the initial permissions screen (not returnToPrevious).
  static void setPermissionsCompletedOnce() {
    _permissionsCompletedOnce = true;
  }

  static const List<Permission> _requiredPermissions = [
    Permission.location,
    Permission.camera,
    Permission.notification,
  ];

  /// Maps [Permission] to a stable key for storage/UI.
  static String permissionKey(Permission p) {
    if (p == Permission.location) return 'location';
    if (p == Permission.camera) return 'camera';
    if (p == Permission.notification) return 'notification';
    return p.toString();
  }

  static PermissionStatusType _fromStatus(PermissionStatus status) {
    if (status.isGranted) return PermissionStatusType.granted;
    if (status.isPermanentlyDenied) return PermissionStatusType.permanentlyDenied;
    return PermissionStatusType.denied;
  }

  /// Returns current status for each of the three permissions.
  static Future<Map<Permission, PermissionStatusType>> checkAllPermissions() async {
    final map = <Permission, PermissionStatusType>{};
    for (final p in _requiredPermissions) {
      final status = await p.status;
      map[p] = _fromStatus(status);
    }
    return map;
  }

  /// True if all three permissions are granted.
  static Future<bool> areAllGranted() async {
    final map = await checkAllPermissions();
    return map.values.every((s) => s == PermissionStatusType.granted);
  }

  /// Request location. Returns new status. Caller should open app settings if permanently denied.
  static Future<PermissionStatusType> requestLocation() async {
    final status = await Permission.location.request();
    return _fromStatus(status);
  }

  /// Request camera. Returns new status. Caller should open app settings if permanently denied.
  static Future<PermissionStatusType> requestCamera() async {
    final status = await Permission.camera.request();
    return _fromStatus(status);
  }

  /// Request notifications (push). Returns new status. Caller should open app settings if permanently denied.
  static Future<PermissionStatusType> requestNotifications() async {
    final status = await Permission.notification.request();
    return _fromStatus(status);
  }

  /// Request a specific permission. Returns new status. Caller should open app settings if permanently denied.
  static Future<PermissionStatusType> request(Permission permission) async {
    final status = await permission.request();
    return _fromStatus(status);
  }
}
