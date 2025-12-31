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

  Future<void> _onAccept(
    AcceptRetrivalRequest event,
    Emitter<RetrivalRequestState> emit,
  ) async {
    emit(const RetrivalRequestLoading());
    try {
      print('🚀 Attempting to accept session: ${event.sessionId}');
      
      // Get stored location or fetch new one
      var locationData = await TokenStorage.getCurrentLocation();
      
      if (locationData == null) {
        print('📍 No stored location found, getting current location...');
        // Request permission if needed
        LocationPermission permission = await LocationService.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await LocationService.requestPermission();
        }
        
        if (permission != LocationPermission.denied && 
            permission != LocationPermission.deniedForever) {
          final position = await LocationService.getCurrentLocation();
          final latitude = position.latitude;
          final longitude = position.longitude;
          final location = '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
          
          locationData = {
            'latitude': latitude,
            'longitude': longitude,
            'location': location,
          };
          
          // Save for future use
          await TokenStorage.saveCurrentLocation(
            latitude: latitude,
            longitude: longitude,
            location: location,
          );
        } else {
          throw Exception('Location permission is required to accept session');
        }
      }
      
      final response = await RetrievalAcceptApiService.acceptSession(
        sessionId: event.sessionId,
        latitude: locationData['latitude'] as double,
        longitude: locationData['longitude'] as double,
        location: locationData['location'] as String,
      );
      print('✅ Accept API succeeded: ${response.message}');
      emit(RetrivalRequestAccepted(response.message));
    } catch (e) {
      final errorMsg = (e is Exception) ? e.toString() : 'Failed to accept request';
      print('❌ Accept API failed: $errorMsg');

      // If the session is already in a processed state, treat it as accepted
      if (errorMsg.contains('RETRIEVING') && errorMsg.contains('expected ASSIGNED')) {
        print('⚠️ Session already in RETRIEVING status, treating as accepted');
        emit(const RetrivalRequestAccepted('Request accepted (session was already in progress)'));
      } else if (errorMsg.contains('ARRIVED') && errorMsg.contains('expected ASSIGNED')) {
        print('⚠️ Session already in ARRIVED status, treating as accepted');
        emit(const RetrivalRequestAccepted('Request already processed (session has arrived)'));
      } else {
        emit(RetrivalRequestError(errorMsg));
      }
    }
  }
}
