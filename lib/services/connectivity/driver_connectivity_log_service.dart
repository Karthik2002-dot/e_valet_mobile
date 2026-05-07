import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:niloufer_valet_mobile/api/driver/connectivity_log_api_service.dart';
import 'package:niloufer_valet_mobile/models/driver/connectivity/connectivity_log_batch_request.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';

/// Logs driver connectivity transitions locally and POSTs batches on a 5h cadence
/// (or immediately when back online if a flush was due while offline).
///
/// Payload enums (backend / Prisma): `ConnectivityStatus` CONNECTED | DISCONNECTED;
/// `NetworkType` WIFI | MOBILE_DATA | NONE.
class DriverConnectivityLogService {
  DriverConnectivityLogService._();
  static final DriverConnectivityLogService instance = DriverConnectivityLogService._();

  static const Duration _flushInterval = Duration(hours: 5);
  static const String _statusConnected = 'CONNECTED';
  static const String _statusDisconnected = 'DISCONNECTED';

  /// [NetworkType] — only these three strings are sent.
  static const String _netWifi = 'WIFI';
  static const String _netMobileData = 'MOBILE_DATA';
  static const String _netNone = 'NONE';

  bool? _baselineRecorded;
  bool? _lastOnline;
  String? _lastNetworkLabel;

  /// Call after a successful clock-in so shift/outlet context exists and the first flush is scheduled.
  Future<void> onShiftActiveAfterClockIn({
    required int shiftId,
    required int outletId,
  }) async {
    if (shiftId <= 0 || outletId <= 0) return;
    await TokenStorage.saveDriverConnectivityShiftContext(
      shiftId: shiftId,
      outletId: outletId,
    );
    await TokenStorage.saveConnectivityNextFlushDue(
      DateTime.now().toUtc().add(_flushInterval),
    );
    _baselineRecorded = null;
    _lastOnline = null;
    _lastNetworkLabel = null;
  }

  /// Sync shift/outlet from GET /drivers/me/status (e.g. after app restart).
  Future<void> syncFromDriverStatus({
    required int shiftId,
    required int outletId,
    required bool isOffline,
  }) async {
    if (isOffline || shiftId <= 0 || outletId <= 0) return;
    await TokenStorage.saveDriverConnectivityShiftContext(
      shiftId: shiftId,
      outletId: outletId,
    );
    final existing = await TokenStorage.getConnectivityNextFlushDue();
    if (existing == null) {
      await TokenStorage.saveConnectivityNextFlushDue(
        DateTime.now().toUtc().add(_flushInterval),
      );
    }
  }

  Future<void> clearOnLogout() async {
    await TokenStorage.clearDriverConnectivityLogData();
    _baselineRecorded = null;
    _lastOnline = null;
    _lastNetworkLabel = null;
  }

  /// POSTs queued connectivity events **before** tokens are cleared (e.g. logout).
  /// Ignores the 5-hour schedule. No-op if offline, no shift, or nothing queued.
  Future<void> flushPendingIgnoringSchedule() async {
    final shiftId = await TokenStorage.getDriverConnectivityShiftId();
    if (shiftId == null || shiftId <= 0) return;

    final outletId = await TokenStorage.getDriverConnectivityOutletId();
    if (outletId == null || outletId <= 0) return;

    final events = await _loadEvents();
    if (events.isEmpty) return;

    final connectivity = Connectivity();
    final results = await connectivity.checkConnectivity();
    if (!_isOnline(results)) {
      log(
        'DriverConnectivityLogService: pre-logout flush skipped (device offline)',
      );
      return;
    }

    try {
      await ConnectivityLogApiService.postBatch(
        ConnectivityLogBatchRequest(
          outletId: outletId,
          shiftId: shiftId,
          events: events,
        ),
      );
      await TokenStorage.clearConnectivityPendingEvents();
      log(
        'DriverConnectivityLogService: pre-logout flushed ${events.length} event(s)',
      );
    } catch (e, st) {
      log(
        'DriverConnectivityLogService: pre-logout flush failed (logout continues): $e',
        stackTrace: st,
      );
    }
  }

  /// Connectivity stream callback. Logs CONNECTED / DISCONNECTED transitions for drivers on shift.
  Future<void> handleConnectivityResults(List<ConnectivityResult> results) async {
    final shiftId = await TokenStorage.getDriverConnectivityShiftId();
    if (shiftId == null || shiftId <= 0) {
      _baselineRecorded = null;
      _lastOnline = null;
      _lastNetworkLabel = null;
      return;
    }

    final online = _isOnline(results);
    final label = _networkTypeLabel(results);

    if (_baselineRecorded != true) {
      _lastOnline = online;
      _lastNetworkLabel = label;
      _baselineRecorded = true;
      return;
    }

    if (online == _lastOnline && label == _lastNetworkLabel) {
      return;
    }

    _lastOnline = online;
    _lastNetworkLabel = label;

    late final String status;
    late final String networkType;
    if (online) {
      status = _statusConnected;
      networkType = label;
    } else {
      status = _statusDisconnected;
      networkType = _netNone;
    }

    await _appendEvent(
      ConnectivityLogEventItem(
        status: status,
        networkType: networkType,
        occurredAt: _formatOccurredAt(DateTime.now().toUtc()),
      ),
    );

    if (online) {
      await tryFlushIfDue();
    }
  }

  /// Called from a periodic timer and when returning online.
  Future<void> tryFlushIfDue() async {
    final shiftId = await TokenStorage.getDriverConnectivityShiftId();
    if (shiftId == null || shiftId <= 0) return;

    final connectivity = Connectivity();
    final results = await connectivity.checkConnectivity();
    if (!_isOnline(results)) {
      return;
    }

    final outletId = await TokenStorage.getDriverConnectivityOutletId();
    if (outletId == null || outletId <= 0) return;

    final events = await _loadEvents();
    if (events.isEmpty) {
      await _rollNextFlushIfPastDueOnly();
      return;
    }

    final nextDue = await TokenStorage.getConnectivityNextFlushDue();
    final now = DateTime.now().toUtc();
    if (nextDue != null && now.isBefore(nextDue)) {
      return;
    }

    try {
      await ConnectivityLogApiService.postBatch(
        ConnectivityLogBatchRequest(
          outletId: outletId,
          shiftId: shiftId,
          events: events,
        ),
      );
      await TokenStorage.clearConnectivityPendingEvents();
      await TokenStorage.saveConnectivityNextFlushDue(
        now.add(_flushInterval),
      );
      log('DriverConnectivityLogService: flushed ${events.length} event(s)');
    } catch (e, st) {
      log(
        'DriverConnectivityLogService: batch flush failed (will retry): $e',
        stackTrace: st,
      );
    }
  }

  Future<void> _rollNextFlushIfPastDueOnly() async {
    final nextDue = await TokenStorage.getConnectivityNextFlushDue();
    final now = DateTime.now().toUtc();
    if (nextDue != null && !now.isBefore(nextDue)) {
      await TokenStorage.saveConnectivityNextFlushDue(now.add(_flushInterval));
    }
  }

  Future<void> _appendEvent(ConnectivityLogEventItem item) async {
    final list = await _loadEvents();
    list.add(item);
    await TokenStorage.saveConnectivityPendingEventsJson(
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<ConnectivityLogEventItem>> _loadEvents() async {
    final raw = await TokenStorage.getConnectivityPendingEventsJson();
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => e as Map<String, dynamic>)
          .map(
            (m) => ConnectivityLogEventItem(
              status: (m['status'] as String? ?? '').trim(),
              networkType: _normalizeStoredNetworkType(m['networkType'] as String? ?? ''),
              occurredAt: m['occurredAt'] as String? ?? '',
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Legacy app versions used CELLULAR; backend enum is MOBILE_DATA.
  static String _normalizeStoredNetworkType(String raw) {
    final s = raw.trim();
    if (s.toUpperCase() == 'CELLULAR') return _netMobileData;
    return s;
  }

  static String _formatOccurredAt(DateTime utc) {
    // e.g. 2026-05-07T09:39:18.000Z
    return utc.toIso8601String();
  }

  static bool _isOnline(List<ConnectivityResult> results) {
    return results.isNotEmpty &&
        results.any((r) => r != ConnectivityResult.none);
  }

  /// Maps [ConnectivityResult] to API [NetworkType]: WIFI | MOBILE_DATA | NONE.
  static String _networkTypeLabel(List<ConnectivityResult> results) {
    if (results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none)) {
      return _netNone;
    }
    if (results.contains(ConnectivityResult.wifi)) return _netWifi;
    if (results.contains(ConnectivityResult.mobile)) return _netMobileData;
    // ethernet, vpn, bluetooth, other: no separate enum — treat as cellular-style access
    if (results.any((r) => r != ConnectivityResult.none)) {
      return _netMobileData;
    }
    return _netNone;
  }
}
