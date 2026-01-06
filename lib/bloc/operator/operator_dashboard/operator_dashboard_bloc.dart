import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_dashboard_api_service.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_available_drivers_api_service.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_retrieval_requests_api_service.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_digital_key_rack_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_bloc.dart';
import 'operator_dashboard_event.dart';
import 'operator_dashboard_state.dart';

class OperatorDashboardBloc
    extends Bloc<OperatorDashboardEvent, OperatorDashboardState> {
  final WebSocketBloc? webSocketBloc;
  final String outletId;
  StreamSubscription<dynamic>? _sessionStatusSubscription;
  StreamSubscription<dynamic>? _statsUpdateSubscription;

  OperatorDashboardBloc({
    this.webSocketBloc,
    required this.outletId,
  }) : super(const OperatorDashboardInitial()) {
    on<FetchDashboardKpis>(_onFetchDashboardKpis);
    on<RefreshDashboardKpisSilently>(_onRefreshDashboardKpisSilently);

    // Setup WebSocket listeners if WebSocketBloc is provided
    _setupWebSocketListeners();
  }

  /// Setup WebSocket listeners for real-time updates
  void _setupWebSocketListeners() {
    if (webSocketBloc == null) {
      print(
        'WebSocketBloc not provided to OperatorDashboardBloc. '
        'Real-time updates will be disabled.',
      );
      return;
    }

    try {
      // Listen to session:status_changed event
      final sessionStatusStream =
          webSocketBloc!.service.getEventStream('session:status_changed');

      _sessionStatusSubscription = sessionStatusStream.listen(
        (data) {
          // Silently refresh KPIs when session status changes
          add(
            RefreshDashboardKpisSilently(
              outletId: outletId,
            ),
          );
        },
        onError: (error) {
          print('Error listening to session status updates: $error');
        },
      );

      // Listen to outlet:stats_updated event
      final statsStream =
          webSocketBloc!.service.getEventStream('outlet:stats_updated');

      _statsUpdateSubscription = statsStream.listen(
        (data) {
          // Silently refresh KPIs when stats update is received
          add(
            RefreshDashboardKpisSilently(
              outletId: outletId,
            ),
          );
        },
        onError: (error) {
          print('Error listening to stats updates: $error');
        },
      );
    } catch (e) {
      print('Error setting up WebSocket listeners: $e');
    }
  }

  Future<void> _onFetchDashboardKpis(
    FetchDashboardKpis event,
    Emitter<OperatorDashboardState> emit,
  ) async {
    emit(const OperatorDashboardLoading());
    try {
      // Fetch KPIs, available drivers, retrieval requests, and digital key rack in parallel
      final results = await Future.wait([
        OperatorDashboardApiService.getDashboardKpis(
          outletId: event.outletId,
        ),
        OperatorAvailableDriversApiService.getAvailableDrivers(
          outletId: event.outletId,
        ),
        OperatorRetrievalRequestsApiService.getRetrievalRequests(
          outletId: event.outletId,
        ),
        OperatorDigitalKeyRackApiService.getDigitalKeyRack(
          outletId: event.outletId,
        ),
      ]);

      final kpis = results[0] as dynamic;
      final availableDrivers = results[1] as dynamic;
      final retrievalRequests = results[2] as dynamic;
      final digitalKeyRack = results[3] as dynamic;

      emit(OperatorDashboardLoaded(
        kpis: kpis,
        availableDrivers: availableDrivers,
        retrievalRequests: retrievalRequests,
        digitalKeyRack: digitalKeyRack,
      ));
    } catch (e) {
      emit(OperatorDashboardError(e.toString()));
    }
  }

  /// Refresh KPIs and available drivers silently without showing loading state
  /// Used for real-time WebSocket updates
  Future<void> _onRefreshDashboardKpisSilently(
    RefreshDashboardKpisSilently event,
    Emitter<OperatorDashboardState> emit,
  ) async {
    // Only refresh if we're already in a loaded state
    if (state is! OperatorDashboardLoaded) {
      return;
    }

    final currentState = state as OperatorDashboardLoaded;

    try {
      // Fetch KPIs and available drivers silently in the background
      final results = await Future.wait([
        OperatorDashboardApiService.getDashboardKpis(
          outletId: event.outletId,
        ),
        OperatorAvailableDriversApiService.getAvailableDrivers(
          outletId: event.outletId,
        ),
      ]);

      final kpis = results[0] as dynamic;
      final availableDrivers = results[1] as dynamic;

      // Emit updated state with new KPIs and available drivers
      emit(OperatorDashboardLoaded(
        kpis: kpis,
        availableDrivers: availableDrivers,
        retrievalRequests: currentState.retrievalRequests,
        digitalKeyRack: currentState.digitalKeyRack,
      ));
    } catch (e) {
      // Silently fail - don't show error for background updates
      // Just keep the current state
      print('Silent KPI and available drivers refresh failed: $e');
    }
  }

  @override
  Future<void> close() async {
    // Cancel WebSocket subscriptions
    await _sessionStatusSubscription?.cancel();
    await _statsUpdateSubscription?.cancel();
    return super.close();
  }
}
