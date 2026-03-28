import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:niloufer_valet_mobile/api/driver/assigned_sessions_api_service.dart';
import 'package:niloufer_valet_mobile/api/driver/sessions_pending_api.dart';
import 'package:niloufer_valet_mobile/api/operator/operator_dashboard/operator_assign_retrieval_api_service.dart';
import 'package:niloufer_valet_mobile/bloc/driver/confirm_arrival/confirm_arrival_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/confirm_arrival/confirm_arrival_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/confirm_arrival/confirm_arrival_state.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/car_details_screen.dart';
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/confirm_arrival_widgets/car_information_card.dart';
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/confirm_arrival_widgets/handover_buttons_section.dart';
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/confirm_arrival_widgets/slide_to_confirm_button.dart';
import 'package:niloufer_valet_mobile/ui/driver/customer_missing/customer_missing_dialog.dart';

class ConfirmArrivalScreen extends StatefulWidget {
  final AssignedSession session;
  final bool preventBackNavigation;
  final bool showHandoverOnLoad;

  /// When set, the disable countdown is counted from this moment (when accept API was triggered).
  /// Passed from Collect Keys flow so the button enables after CONFIRM_ARRIVAL_DISABLE_SECONDS, not after screen open.
  final DateTime? acceptTriggeredAt;

  /// Total seconds the button stays disabled after acceptTriggeredAt. If null, uses CONFIRM_ARRIVAL_DISABLE_SECONDS from .env (default 10).
  final int? disableConfirmArrivalForSeconds;

  const ConfirmArrivalScreen({
    super.key,
    required this.session,
    this.preventBackNavigation = false,
    this.showHandoverOnLoad = false,
    this.acceptTriggeredAt,
    this.disableConfirmArrivalForSeconds,
  });

  @override
  State<ConfirmArrivalScreen> createState() => _ConfirmArrivalScreenState();
}

/// Polling interval in seconds to detect operator override (Parked/Completed).
const int _operatorOverridePollIntervalSeconds = 5;

class _ConfirmArrivalScreenState extends State<ConfirmArrivalScreen> {
  bool _showHandoverButtons = false;
  bool _confirmArrivalButtonEnabled = true;
  int _confirmArrivalRemainingSeconds = 0;
  Timer? _enableConfirmArrivalTimer;
  Timer? _operatorOverridePollTimer;

  /// After Confirm Arrival API success, Customer Missing button is disabled until this time (duration from CUSTOMER_MISSING_DISABLE_SECONDS in .env).
  DateTime? _customerMissingDisabledUntil;
  final GlobalKey<HandoverButtonsSectionState> _handoverButtonsKey =
      GlobalKey<HandoverButtonsSectionState>();

  static int _confirmArrivalDisableSecondsFromEnv() {
    final v = dotenv.env['CONFIRM_ARRIVAL_DISABLE_SECONDS'];
    if (v == null || v.isEmpty) return 10;
    return int.tryParse(v.trim()) ?? 10;
  }

  static int _customerMissingDisableSecondsFromEnv() {
    final v = dotenv.env['CUSTOMER_MISSING_DISABLE_SECONDS'];
    if (v == null || v.isEmpty) return 60;
    return int.tryParse(v.trim()) ?? 60;
  }

  @override
  void initState() {
    super.initState();
    _showHandoverButtons = widget.showHandoverOnLoad;
    final triggeredAt = widget.acceptTriggeredAt;
    final totalSeconds = widget.disableConfirmArrivalForSeconds ??
        _confirmArrivalDisableSecondsFromEnv();
    if (triggeredAt != null && totalSeconds > 0) {
      final elapsed = DateTime.now().difference(triggeredAt).inSeconds;
      final remaining = totalSeconds - elapsed;
      if (remaining > 0) {
        _confirmArrivalButtonEnabled = false;
        _confirmArrivalRemainingSeconds = remaining;
        _enableConfirmArrivalTimer = Timer.periodic(
          const Duration(seconds: 1),
          (_) {
            if (!mounted) return;
            setState(() {
              _confirmArrivalRemainingSeconds =
                  (_confirmArrivalRemainingSeconds - 1).clamp(0, totalSeconds);
              if (_confirmArrivalRemainingSeconds <= 0) {
                _enableConfirmArrivalTimer?.cancel();
                _enableConfirmArrivalTimer = null;
                _confirmArrivalButtonEnabled = true;
              }
            });
          },
        );
      }
    }
    _startOperatorOverridePolling();
  }

  /// Polls assigned sessions every 5 seconds. When operator overrides transaction
  /// status to Parked/Completed from Operator Dashboard, the session is removed
  /// from assigned-to-me. We detect that and pop to Home so valet becomes available.
  void _startOperatorOverridePolling() {
    _operatorOverridePollTimer?.cancel();
    _operatorOverridePollTimer = Timer.periodic(
      const Duration(seconds: _operatorOverridePollIntervalSeconds),
      (_) => _checkOperatorOverride(),
    );
  }

  Future<void> _checkOperatorOverride() async {
    if (!mounted) return;
    try {
      // Avoid popping while confirm arrival / handover API is in flight (race → double pop → blank screen).
      try {
        final blocState = context.read<ConfirmArrivalBloc>().state;
        if (blocState is ConfirmArrivalLoading) return;
      } catch (_) {}

      // 1) GET /operators/assign-retrieval - primary source for status when operator changes in Car Logs
      final assignmentStatus =
          await OperatorAssignRetrievalApiService.getAssignmentStatus(
        sessionId: widget.session.id,
      );
      if (!mounted) return;
      if (assignmentStatus != null) {
        if (assignmentStatus.isParked || assignmentStatus.isCompleted) {
          _operatorOverridePollTimer?.cancel();
          _operatorOverridePollTimer = null;
          if (mounted) {
            final t = context.read<AppTranslationsNotifier>();
            SnackBars.showSuccessSnackBar(
              context,
              t.getByKey(
                'transactionCompletedByOperator',
                TextConstants.transactionCompletedByOperator,
              ),
            );
            _safePopAfterSnackBar();
          }
          return;
        }
        if (!_showHandoverButtons && assignmentStatus.isArrived) {
          setState(() => _showHandoverButtons = true);
          return;
        }
      }

      // 2) Fallback: Check assigned sessions - session removed when operator completes
      final sessions = await AssignedSessionsApiService.fetchAssignedSessions();
      if (!mounted) return;
      final sessionStillAssigned =
          sessions.any((s) => s.id == widget.session.id);
      if (!sessionStillAssigned) {
        _operatorOverridePollTimer?.cancel();
        _operatorOverridePollTimer = null;
        if (mounted) {
          final t = context.read<AppTranslationsNotifier>();
          SnackBars.showSuccessSnackBar(
            context,
            t.getByKey(
              'transactionCompletedByOperator',
              TextConstants.transactionCompletedByOperator,
            ),
          );
          _safePopAfterSnackBar();
        }
        return;
      }

      // 3) Fallback: GET /sessions/pending - check if operator changed to ARRIVED
      if (!_showHandoverButtons) {
        final pending = await SessionsPendingApiService.getPendingSessions();
        if (!mounted) return;
        final matching = pending.sessions
            .where((s) => s.sessionId == widget.session.id)
            .toList();
        if (matching.isNotEmpty && matching.first.isArrived) {
          setState(() => _showHandoverButtons = true);
        }
      }
    } catch (_) {
      // Silently ignore polling errors; will retry on next interval
    }
  }

  void _cancelOperatorOverridePolling() {
    _operatorOverridePollTimer?.cancel();
    _operatorOverridePollTimer = null;
  }

  /// Pop once on the next frame after snackbar schedules; cancels operator polling
  /// first to avoid a race with [_checkOperatorOverride] (double pop → blank screen).
  void _safePopAfterSnackBar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _cancelOperatorOverridePolling();
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _enableConfirmArrivalTimer?.cancel();
    _cancelOperatorOverridePolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTranslationsNotifier>();
    return BlocProvider(
      create: (context) => ConfirmArrivalBloc(),
      child: BlocListener<ConfirmArrivalBloc, ConfirmArrivalState>(
        listener: (context, state) {
          if (state is ConfirmArrivalSuccess) {
            SnackBars.showSuccessSnackBar(context, state.message);
            final customerMissingSecs = _customerMissingDisableSecondsFromEnv();
            setState(() {
              _showHandoverButtons = true;
              _customerMissingDisabledUntil =
                  DateTime.now().add(Duration(seconds: customerMissingSecs));
            });
          } else if (state is ConfirmArrivalError) {
            if (state.shouldNavigateToHandover) {
              SnackBars.showSuccessSnackBar(context, state.message);
              final customerMissingSecs =
                  _customerMissingDisableSecondsFromEnv();
              setState(() {
                _showHandoverButtons = true;
                _customerMissingDisabledUntil =
                    DateTime.now().add(Duration(seconds: customerMissingSecs));
              });
            } else {
              SnackBars.showErrorSnackBar(context, state.message);
            }
          } else if (state is ConfirmHandoverSuccess) {
            if (!context.mounted) return;
            _cancelOperatorOverridePolling();
            SnackBars.showSuccessSnackBar(context, state.message);
            // Pop next frame so SnackBar attaches; one pop only — avoids blank stack.
            _safePopAfterSnackBar();
          } else if (state is ConfirmHandoverError) {
            SnackBars.showErrorSnackBar(context, state.message);
          }
        },
        child: BlocBuilder<ConfirmArrivalBloc, ConfirmArrivalState>(
          builder: (context, state) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final isLoading = state is ConfirmArrivalLoading;

            // Layout: 40% image, 30% data, 30% button (flex 4 : 3 : 3)
            final scaffoldContent = Scaffold(
              backgroundColor: AppColors.lightBeigeBackground,
              appBar: const CustomAppBar(),
              body: Column(
                children: [
                  SizedBox(height: screenHeight * 0.01),
                  Center(
                    child: TextComponent(
                      labelText: t.get(TextConstants.retrievalRequest),
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  // 40% – image
                  Expanded(
                    flex: 4,
                    child: CarImageSection(session: widget.session),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  // 30% – data
                  Expanded(
                    flex: 3,
                    child: CarDetailsSection(session: widget.session),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  // 30% – instruction + button(s)
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.01,
                      ),
                      child: _showHandoverButtons
                          ? HandoverButtonsSection(
                              key: _handoverButtonsKey,
                              isLoading: isLoading,
                              customerMissingDisabledUntil:
                                  _customerMissingDisabledUntil,
                              onConfirmHandover: () {
                                context.read<ConfirmArrivalBloc>().add(
                                      ConfirmHandoverRequested(
                                          sessionId: widget.session.id),
                                    );
                              },
                              onCustomerMissing: () {
                                return CustomerMissingDialog.show(
                                  context,
                                  sessionId: widget.session.id,
                                  onCancel: () {
                                    _handoverButtonsKey.currentState
                                        ?.resetCustomerMissingButton();
                                  },
                                );
                              },
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextComponent(
                                  labelText: t.getByKey(
                                      'pressBelowToConfirmArrival',
                                      TextConstants.pressBelowToConfirmArrival),
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Expanded(
                                  child: SlideToConfirmButton(
                                    sessionId: widget.session.id,
                                    isLoading: isLoading,
                                    enabled: _confirmArrivalButtonEnabled,
                                    disabledRemainingSeconds:
                                        _confirmArrivalRemainingSeconds,
                                    onConfirm: () {
                                      context.read<ConfirmArrivalBloc>().add(
                                            ConfirmArrivalRequested(
                                                sessionId: widget.session.id),
                                          );
                                    },
                                    useBigStyle: true,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const Footer(),
                ],
              ),
            );

            // Wrap with PopScope to prevent back navigation if needed
            if (widget.preventBackNavigation) {
              return PopScope(
                canPop: false, // Prevent back button from navigating back
                child: scaffoldContent,
              );
            }

            return scaffoldContent;
          },
        ),
      ),
    );
  }
}
