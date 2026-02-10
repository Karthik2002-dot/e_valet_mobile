import 'package:hive_flutter/hive_flutter.dart';
import 'package:niloufer_valet_mobile/api/driver/session_api_service.dart';
import 'package:niloufer_valet_mobile/models/driver/session/checkin_request.dart';
import 'package:niloufer_valet_mobile/api/driver/image_API.dart';
import 'package:niloufer_valet_mobile/api/driver/re-park_api.dart';
import 'package:niloufer_valet_mobile/models/driver/park/offline_parking_photo.dart';
import 'package:niloufer_valet_mobile/models/driver/park/park_request.dart';
import 'package:niloufer_valet_mobile/models/driver/re-park/repark_photo_request.dart';
import 'package:flutter/foundation.dart';

class OfflineParkingService {
  static const String _boxName = 'offline_checkins';
  static const String _photoBoxName = 'offline_photos';

  static Future<void> init() async {
    await Hive.openBox<CheckinRequest>(_boxName);
    await Hive.openBox<OfflineParkingPhoto>(_photoBoxName);
  }

  static Future<void> saveParkingPhoto(OfflineParkingPhoto photo) async {
    final box = Hive.box<OfflineParkingPhoto>(_photoBoxName);
    await box.add(photo);
    debugPrint(
        'Offline photo saved: ${photo.imagePath} for session ${photo.sessionId}');
  }

  static Future<List<CheckinRequest>> getPendingCheckins() async {
    final box = Hive.box<CheckinRequest>(_boxName);
    return box.values.toList();
  }

  static Future<List<OfflineParkingPhoto>> getPendingPhotos() async {
    final box = Hive.box<OfflineParkingPhoto>(_photoBoxName);
    return box.values.toList();
  }

  static Future<void> removeCheckin(int index) async {
    final box = Hive.box<CheckinRequest>(_boxName);
    await box.deleteAt(index);
  }

  static Future<void> clearAll() async {
    final box = Hive.box<CheckinRequest>(_boxName);
    await box.clear();
    final photoBox = Hive.box<OfflineParkingPhoto>(_photoBoxName);
    await photoBox.clear();
  }

  static Future<void> syncPendingData() async {
    await _syncCheckins();
    await _syncPhotos();
  }

  static Future<void> _syncCheckins() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<CheckinRequest>(_boxName);
    }

    final box = Hive.box<CheckinRequest>(_boxName);
    if (box.isEmpty) return;

    debugPrint('Syncing ${box.length} pending checkins...');

    // We need to iterate carefully since we might be modifying the box (delete)
    // It's safer to get all keys and values first
    final checkins = box.toMap(); // key -> value

    for (final entry in checkins.entries) {
      final key = entry.key;
      final request = entry.value;
      bool success = false;
      int attempts = 0;

      while (!success && attempts < 3) {
        try {
          debugPrint(
              'Syncing checkin for card: ${request.cardNumber} (Attempt ${attempts + 1})');
          await SessionApiService.checkin(request);
          await box.delete(key);
          debugPrint('Successfully synced and removed checkin: $key');
          success = true;
        } catch (e) {
          attempts++;
          debugPrint('Failed to sync checkin $key: $e');
          if (attempts < 3) {
            debugPrint('Retrying in 5 seconds...');
            await Future.delayed(const Duration(seconds: 5));
          }
        }
      }
    }
  }

  static Future<void> _syncPhotos() async {
    if (!Hive.isBoxOpen(_photoBoxName)) {
      await Hive.openBox<OfflineParkingPhoto>(_photoBoxName);
    }

    final box = Hive.box<OfflineParkingPhoto>(_photoBoxName);
    if (box.isEmpty) return;

    debugPrint('Syncing ${box.length} pending photos...');

    final photos = box.toMap();

    for (final entry in photos.entries) {
      final key = entry.key;
      final photo = entry.value;
      bool success = false;
      int attempts = 0;

      while (!success && attempts < 3) {
        try {
          debugPrint(
              'Syncing photo for session: ${photo.sessionId} (Attempt ${attempts + 1})');

          if (photo.isReparking) {
            final reparkRequest = ReparkPhotoRequest(
              imagePath: photo.imagePath,
              latitude: photo.latitude,
              longitude: photo.longitude,
              accuracy: photo.accuracy,
              parkingLocation: photo.parkingLocation,
            );
            await ReparkApiService.uploadReparkPhoto(
              sessionId: photo.sessionId,
              request: reparkRequest,
            );
          } else {
            final parkRequest = ParkRequest(
              imagePath: photo.imagePath,
              latitude: photo.latitude,
              longitude: photo.longitude,
              accuracy: photo.accuracy,
              parkingLocation: photo.parkingLocation,
            );
            await ImageApiService.uploadParkingPhoto(
              request: parkRequest,
              sessionId: photo.sessionId,
            );
          }

          await box.delete(key);
          debugPrint('Successfully synced and removed photo: $key');
          success = true;
        } catch (e) {
          attempts++;
          debugPrint('Failed to sync photo $key: $e');
          if (attempts < 3) {
            debugPrint('Retrying in 5 seconds...');
            await Future.delayed(const Duration(seconds: 5));
          }
        }
      }
    }
  }
}
