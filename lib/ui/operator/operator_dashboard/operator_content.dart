import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_dashboard/operator_dashboard_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_dashboard/operator_dashboard_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_dashboard/operator_dashboard_state.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/skeleton_loader.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/dashboard_kpi_grid.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/dashboard_three_column_layout.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/widgets/manual_request_widget.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_bloc.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/operator_available_drivers_response.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/retrieval_requests_response.dart';
import 'package:niloufer_valet_mobile/services/notification/text_to_speech_service.dart';

class DashboardContent extends StatefulWidget {
  final void Function(VoidCallback)? onRefreshReady;
  final void Function(int)? onNavigateToTab;

  const DashboardContent({
    super.key,
    this.onRefreshReady,
    this.onNavigateToTab,
  });

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  late OperatorDashboardBloc _dashboardBloc;
  final String _outletId = dotenv.env['OUTLET_ID'] ?? '1';
  final TextToSpeechService _ttsService = TextToSpeechService();
  final Set<String> _knownRequestIds = <String>{};
  final Set<String> _highlightedRequestIds = <String>{};
  final Map<String, Timer> _highlightTimers = <String, Timer>{};
  final List<String> _ttsQueue = <String>[];
  final Duration _ttsPause = const Duration(milliseconds: 500);
  final Duration _highlightDuration = const Duration(seconds: 30);
  bool _isSpeaking = false;
  bool _hasLoadedOnce = false;

  /// Cache of last loaded state so assignment states don't show a blank screen.
  OperatorDashboardLoaded? _lastLoadedState;

  /// Auto mode toggle: when on, retrieval requests refresh every 30 seconds in the background. Default off; user turns on manually.
  bool _isAutoMode = false;

  /// Periodic timer for silent background refresh of retrieval requests every 30 seconds.
  Timer? _retrievalRequestsRefreshTimer;

  static const Duration _retrievalRequestsRefreshInterval =
      Duration(seconds: 30);

  @override
  void initState() {
    super.initState();

    // Get WebSocketBloc from context if available
    final webSocketBloc = context.read<WebSocketBloc?>();

    // Initialize OperatorDashboardBloc with WebSocketBloc for real-time updates
    _dashboardBloc = OperatorDashboardBloc(
      webSocketBloc: webSocketBloc,
      outletId: _outletId,
    );

    // Fetch data when widget initializes
    _dashboardBloc.add(
      FetchDashboardKpis(
        outletId: _outletId,
      ),
    );

    // Start periodic silent refresh when auto mode is on
    if (_isAutoMode) {
      _startRetrievalRequestsRefreshTimer();
    }

    // Expose silent refresh method to parent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onRefreshReady?.call(_silentRefresh);
    });
  }

  /// Silent background refresh of retrieval requests only (no loading indicator).
  void _silentRefreshRetrievalRequests() {
    _dashboardBloc.add(
      RefreshDashboardKpisSilently(
        outletId: _outletId,
        refreshKpis: false,
        refreshDrivers: false,
        refreshRequests: true,
      ),
    );
  }

  void _startRetrievalRequestsRefreshTimer() {
    _retrievalRequestsRefreshTimer?.cancel();
    _retrievalRequestsRefreshTimer = Timer.periodic(
      _retrievalRequestsRefreshInterval,
      (_) => _silentRefreshRetrievalRequests(),
    );
  }

  void _stopRetrievalRequestsRefreshTimer() {
    _retrievalRequestsRefreshTimer?.cancel();
    _retrievalRequestsRefreshTimer = null;
  }

  void _silentRefresh() {
    _dashboardBloc.add(
      RefreshDashboardKpisSilently(
        outletId: _outletId,
        refreshKpis: true,
        refreshDrivers: true,
        refreshRequests: true,
      ),
    );
  }

  void _handleRetrievalRequestUpdates(
    RetrievalRequestsResponse retrievalRequests,
  ) {
    final currentIds =
        retrievalRequests.requests.map((request) => request.sessionId).toSet();

    if (!_hasLoadedOnce) {
      _knownRequestIds
        ..clear()
        ..addAll(currentIds);
      _hasLoadedOnce = true;
      return;
    }

    final newRequests = retrievalRequests.requests.where((request) {
      if (_knownRequestIds.contains(request.sessionId)) {
        return false;
      }
      return request.status.toUpperCase() == 'RETRIEVAL_REQUESTED';
    }).toList();

    _knownRequestIds
      ..clear()
      ..addAll(currentIds);

    if (newRequests.isEmpty) return;

    final announcements =
        newRequests.map((request) => 'Card ${request.cardNumber}').toList();
    _enqueueAnnouncements(announcements);

    for (final request in newRequests) {
      _startHighlight(request.sessionId);
    }
  }

  void _startHighlight(String sessionId) {
    _highlightTimers[sessionId]?.cancel();
    _highlightTimers[sessionId] = Timer(_highlightDuration, () {
      if (!mounted) return;
      setState(() {
        _highlightedRequestIds.remove(sessionId);
        _highlightTimers.remove(sessionId);
      });
    });

    setState(() {
      _highlightedRequestIds.add(sessionId);
    });
  }

  void _enqueueAnnouncements(List<String> announcements) {
    _ttsQueue.addAll(announcements);
    _processTtsQueue();
  }

  Future<void> _processTtsQueue() async {
    if (_isSpeaking || _ttsQueue.isEmpty) return;
    _isSpeaking = true;
    await _ttsService.stop();

    while (_ttsQueue.isNotEmpty) {
      final announcement = _ttsQueue.removeAt(0);
      await _ttsService.speak(announcement);
      if (_ttsQueue.isNotEmpty) {
        await Future.delayed(_ttsPause);
      }
    }

    _isSpeaking = false;
  }

  Widget _buildKpiSkeletonCard(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SkeletonLoader(
              height: MediaQuery.of(context).size.height * 0.012,
              width: MediaQuery.of(context).size.width * 0.12,
              borderRadius: 4,
            ),
            const SizedBox(height: 8),
            SkeletonLoader(
              height: MediaQuery.of(context).size.height * 0.015,
              width: MediaQuery.of(context).size.width * 0.08,
              borderRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _retrievalRequestsRefreshTimer?.cancel();
    _retrievalRequestsRefreshTimer = null;
    for (final timer in _highlightTimers.values) {
      timer.cancel();
    }
    _highlightTimers.clear();
    _ttsService.stop();
    _dashboardBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTranslationsNotifier>();
    return BlocProvider.value(
      value: _dashboardBloc,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextComponent(
                    labelText: t.get(TextConstants.dashboardOverview),
                    color: AppColors.black,
                    fontSize: MediaQuery.of(context).size.height * 0.015,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextComponent(
                        labelText: t.getByKey(
                            'Auto Mode', TextConstants.autoToggleLabel),
                        color: AppColors.black,
                        fontSize: MediaQuery.of(context).size.height * 0.015,
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _isAutoMode,
                        onChanged: (value) {
                          setState(() {
                            _isAutoMode = value;
                            if (_isAutoMode) {
                              _startRetrievalRequestsRefreshTimer();
                            } else {
                              _stopRetrievalRequestsRefreshTimer();
                            }
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child:
                    BlocConsumer<OperatorDashboardBloc, OperatorDashboardState>(
                  listener: (context, state) {
                    if (state is OperatorDashboardLoaded) {
                      _handleRetrievalRequestUpdates(state.retrievalRequests);
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is OperatorDashboardLoading;
                    final isLoaded = state is OperatorDashboardLoaded;
                    final isAssignmentState = state is AssignmentInProgress ||
                        state is AssignmentSuccess ||
                        state is AssignmentError;

                    if (isLoaded) {
                      _lastLoadedState = state;
                    }

                    if (isLoading) {
                      // Show skeleton loaders matching KPI card pattern (Row of 4 cards)
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildKpiSkeletonCard(context),
                              const SizedBox(width: 12),
                              _buildKpiSkeletonCard(context),
                              const SizedBox(width: 12),
                              _buildKpiSkeletonCard(context),
                              const SizedBox(width: 12),
                              _buildKpiSkeletonCard(context),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          Expanded(
                            child: DashboardThreeColumnLayout(
                              retrievalRequests:
                                  RetrievalRequestsResponse(requests: []),
                              availableDrivers:
                                  OperatorAvailableDriversResponse(drivers: []),
                              onAssignmentComplete: () {},
                              isLoading: true,
                              highlightedRequestIds: const <String>{},
                            ),
                          ),
                        ],
                      );
                    } else if (isLoaded ||
                        (isAssignmentState && _lastLoadedState != null)) {
                      final data = isLoaded ? state : _lastLoadedState!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DashboardKpiGrid(
                            kpis: data.kpis,
                            onAvailableValetsTap: () {
                              widget.onNavigateToTab?.call(2);
                            },
                            onTotalVehiclesParkedTap: () {
                              widget.onNavigateToTab?.call(1);
                            },
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015,
                          ),
                          Expanded(
                            child: DashboardThreeColumnLayout(
                              retrievalRequests: data.retrievalRequests,
                              availableDrivers: data.availableDrivers,
                              onAssignmentComplete: () {
                                _dashboardBloc.add(
                                  RefreshDashboardKpisSilently(
                                    outletId: _outletId,
                                    refreshKpis: true,
                                    refreshDrivers: true,
                                    refreshRequests: true,
                                  ),
                                );
                              },
                              isLoading: false,
                              highlightedRequestIds: _highlightedRequestIds,
                            ),
                          ),
                        ],
                      );
                    } else if (state is OperatorDashboardError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextComponent(
                              labelText:
                                  '${t.get(TextConstants.errorLabel)}: ${state.message}',
                              color: AppColors.error,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _dashboardBloc.add(
                                  FetchDashboardKpis(
                                    outletId: _outletId,
                                  ),
                                );
                              },
                              child: TextComponent(
                                labelText: t.get(TextConstants.retryButton),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              ManualRequestWidget(
                onRequestCreated: () {
                  // Refresh the dashboard
                  _dashboardBloc.add(
                    FetchDashboardKpis(
                      outletId: _outletId,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
