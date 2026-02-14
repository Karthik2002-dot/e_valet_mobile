import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/confirm_arrival_widgets/car_information_card.dart';
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/confirm_arrival_widgets/handover_buttons_section.dart';
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/confirm_arrival_widgets/slide_to_confirm_button.dart';
import 'package:niloufer_valet_mobile/ui/driver/customer_missing/customer_missing_dialog.dart';

class ConfirmArrivalScreen extends StatefulWidget {
  final AssignedSession session;
  final bool preventBackNavigation;
  final bool showHandoverOnLoad;

  /// When set, the 30s disable is counted from this moment (when accept API was triggered).
  /// Passed from Collect Keys flow so the button enables 30s after tap, not after screen open.
  final DateTime? acceptTriggeredAt;

  /// Total seconds the button stays disabled after acceptTriggeredAt (e.g. 30).
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
  Timer? _enableConfirmArrivalTimer;

  /// After Confirm Arrival API success, Customer Missing button is disabled until this time (60s).
  DateTime? _customerMissingDisabledUntil;
  final GlobalKey<HandoverButtonsSectionState> _handoverButtonsKey =
      GlobalKey<HandoverButtonsSectionState>();

  @override
  void initState() {
    super.initState();
    _showHandoverButtons = widget.showHandoverOnLoad;
    final triggeredAt = widget.acceptTriggeredAt;
    final totalSeconds = widget.disableConfirmArrivalForSeconds ?? 30;
    if (triggeredAt != null && totalSeconds > 0) {
      final elapsed = DateTime.now().difference(triggeredAt).inSeconds;
      final remaining = totalSeconds - elapsed;
      if (remaining > 0) {
        _confirmArrivalButtonEnabled = false;
        _enableConfirmArrivalTimer = Timer(
          Duration(seconds: remaining),
          () {
            if (mounted) {
              setState(() => _confirmArrivalButtonEnabled = true);
            }
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
    return BlocProvider(
      create: (context) => ConfirmArrivalBloc(),
      child: BlocListener<ConfirmArrivalBloc, ConfirmArrivalState>(
        listener: (context, state) {
          if (state is ConfirmArrivalSuccess) {
            SnackBars.showSuccessSnackBar(context, state.message);
            // Show handover buttons; disable Customer Missing for 60s from now
            setState(() {
              _showHandoverButtons = true;
              _customerMissingDisabledUntil =
                  DateTime.now().add(const Duration(seconds: 60));
            });
          } else if (state is ConfirmArrivalError) {
            if (state.shouldNavigateToHandover) {
              SnackBars.showSuccessSnackBar(context, state.message);
              setState(() {
                _showHandoverButtons = true;
                _customerMissingDisabledUntil =
                    DateTime.now().add(const Duration(seconds: 60));
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
                      labelText: TextConstants.retrievalRequest,
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
                                  labelText:
                                      TextConstants.pressBelowToConfirmArrival,
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
