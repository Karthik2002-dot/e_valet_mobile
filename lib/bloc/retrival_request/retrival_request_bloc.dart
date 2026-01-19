import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'retrival_request_event.dart';
import 'retrival_requesy_state.dart';
import 'package:niloufer_valet_mobile/api/driver/assigned_sessions_api_service.dart';
import 'package:niloufer_valet_mobile/api/driver/retrival_accept_api.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/services/location/location_service.dart';

class RetrivalRequestBloc
    extends Bloc<RetrivalRequestEvent, RetrivalRequestState> {
  RetrivalRequestBloc() : super(const RetrivalRequestInitial()) {
    on<FetchRetrivalRequests>(_onFetch);
    on<AcceptRetrivalRequest>(_onAccept);
    on<UpdateAssignedSessions>(_onUpdateSessions);
  }

  Future<void> _onFetch(
    FetchRetrivalRequests event,
    Emitter<RetrivalRequestState> emit,
  ) async {
    emit(const RetrivalRequestLoading());
    try {
      final sessions = await AssignedSessionsApiService.fetchAssignedSessions();
      emit(RetrivalRequestLoaded(sessions));
    } catch (e) {
      final msg = (e is Exception) ? e.toString() : 'Failed to load requests';
      emit(RetrivalRequestError(msg));
    }
  }

  void _onUpdateSessions(
    UpdateAssignedSessions event,
    Emitter<RetrivalRequestState> emit,
  ) {
    // Update the UI with polled data silently
    emit(RetrivalRequestLoaded(event.sessions));
  }

  Future<void> _onAccept(
    AcceptRetrivalRequest event,
    Emitter<RetrivalRequestState> emit,
  ) async {
    emit(const RetrivalRequestLoading());
    try {
      // Always fetch fresh location with accuracy for accept API
      // Request permission if needed
      LocationPermission permission = await LocationService.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await LocationService.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission is required to accept session');
      }

      // Get current location coordinates with accuracy
      final coordinates = await LocationService.getCurrentCoordinates();
      final latitude = coordinates['latitude']!;
      final longitude = coordinates['longitude']!;
      final accuracy = coordinates['accuracy']!;

      // Validate location is not 0,0
      if (latitude == 0.0 && longitude == 0.0) {
        throw Exception('Invalid location. Please ensure GPS is enabled and try again.');
      }

      // Save location for future use
      final location =
          '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
      await TokenStorage.saveCurrentLocation(
        latitude: latitude,
        longitude: longitude,
        location: location,
      );

      print('[Accept Request] Session ID: ${event.sessionId}');
      print('[Accept Request] Latitude: $latitude, Longitude: $longitude, Accuracy: $accuracy');

      final response = await RetrievalAcceptApiService.acceptSession(
        sessionId: event.sessionId,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
      );
      emit(RetrivalRequestAccepted(response.message));
    } catch (e) {
      final errorMsg =
          (e is Exception) ? e.toString() : 'Failed to accept request';
      print('❌ Accept API failed: $errorMsg');

      // If the session is already in a processed state, treat it as accepted
      if (errorMsg.contains('RETRIEVING') &&
          errorMsg.contains('expected ASSIGNED')) {
        emit(const RetrivalRequestAccepted(
            'Request accepted (session was already in progress)'));
      } else if (errorMsg.contains('ARRIVED') &&
          errorMsg.contains('expected ASSIGNED')) {
        emit(const RetrivalRequestAccepted(
            'Request already processed (session has arrived)'));
      } else {
        emit(RetrivalRequestError(errorMsg));
      }
    }
  }
}
