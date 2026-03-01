import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

class _ConfirmArrivalScreenState extends State<ConfirmArrivalScreen> {
  bool _showHandoverButtons = false;
  bool _confirmArrivalButtonEnabled = true;
  int _confirmArrivalRemainingSeconds = 0;
  Timer? _enableConfirmArrivalTimer;

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
  }

  @override
  void dispose() {
    _enableConfirmArrivalTimer?.cancel();
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
            SnackBars.showSuccessSnackBar(context, state.message);
            // After handover success, navigate back to the same flow
            Navigator.of(context).pop();
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
                                  labelText: t.get(
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
