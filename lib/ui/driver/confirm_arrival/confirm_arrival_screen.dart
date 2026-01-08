import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/api/driver/re-park_request_api.dart';
import 'package:niloufer_valet_mobile/bloc/driver/confirm_arrival/confirm_arrival_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/confirm_arrival/confirm_arrival_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/confirm_arrival/confirm_arrival_state.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_camera_screen.dart';
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/confirm_arrival_widgets/car_information_card.dart';
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/confirm_arrival_widgets/handover_buttons_section.dart';
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/confirm_arrival_widgets/slide_to_confirm_button.dart';
import 'package:niloufer_valet_mobile/ui/driver/customer_missing/customer_missing_dialog.dart';

class ConfirmArrivalScreen extends StatefulWidget {
  final AssignedSession session;

  const ConfirmArrivalScreen({
    super.key,
    required this.session,
  });

  @override
  State<ConfirmArrivalScreen> createState() => _ConfirmArrivalScreenState();
}

class _ConfirmArrivalScreenState extends State<ConfirmArrivalScreen> {
  bool _showHandoverButtons = false;
  final GlobalKey<HandoverButtonsSectionState> _handoverButtonsKey =
      GlobalKey<HandoverButtonsSectionState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConfirmArrivalBloc(),
      child: BlocListener<ConfirmArrivalBloc, ConfirmArrivalState>(
        listener: (context, state) {
          if (state is ConfirmArrivalSuccess) {
            SnackBars.showSuccessSnackBar(context, state.message);
            // Show handover buttons instead of navigating
            setState(() {
              _showHandoverButtons = true;
            });
          } else if (state is ConfirmArrivalError) {
            if (state.shouldNavigateToHandover) {
              SnackBars.showSuccessSnackBar(context, state.message);
              // Show handover buttons instead of navigating
              setState(() {
                _showHandoverButtons = true;
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

            return Scaffold(
              backgroundColor: AppColors.lightBeigeBackground,
              appBar: const CustomAppBar(),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenHeight * 0.02),
                            // Title
                            Center(
                              child: TextComponent(
                                labelText: TextConstants.retrievalRequest,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            // Car Information Card
                            CarInformationCard(session: widget.session),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Show either slide button or handover buttons based on state
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.02,
                    ),
                    child: _showHandoverButtons
                        ? HandoverButtonsSection(
                            key: _handoverButtonsKey,
                            isLoading: isLoading,
                            onConfirmHandover: () {
                              context.read<ConfirmArrivalBloc>().add(
                                    ConfirmHandoverRequested(
                                        sessionId: widget.session.id),
                                  );
                            },
                            onCustomerMissing: () {
                              CustomerMissingDialog.show(
                                context,
                                onProceed: () async {
                                  // Capture context before async call
                                  final currentContext = context;

                                  try {
                                    // Call the re-park API
                                    await ReparkApiService.requestRepark(
                                      sessionId: widget.session.id,
                                      reason: 'CUSTOMER_NO_SHOW',
                                    );

                                    // Check if widget is still mounted before using context
                                    if (!mounted) return;

                                    // Show success message
                                    SnackBars.showSuccessSnackBar(
                                      currentContext,
                                      'Re-park request submitted successfully',
                                    );

                                    Navigator.of(currentContext)
                                        .pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => CarCameraScreen(
                                          sessionId: widget.session.id,
                                          isReparking: true,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    // Check if widget is still mounted before using context
                                    if (!mounted) return;

                                    if (e is ApiException) {
                                      SnackBars.showErrorSnackBar(
                                          currentContext, e.message);
                                    } else {
                                      SnackBars.showErrorSnackBar(
                                        currentContext,
                                        'Failed to submit re-park request. Please try again.',
                                      );
                                    }
                                  }
                                },
                                onCancel: () {
                                  // Reset the customer missing button after cancel
                                  _handoverButtonsKey.currentState
                                      ?.resetCustomerMissingButton();
                                },
                              );
                            },
                          )
                        : SlideToConfirmButton(
                            sessionId: widget.session.id,
                            isLoading: isLoading,
                            onConfirm: () {
                              context.read<ConfirmArrivalBloc>().add(
                                    ConfirmArrivalRequested(
                                        sessionId: widget.session.id),
                                  );
                            },
                          ),
                  ),

                  // Footer at Bottom
                  const Footer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
