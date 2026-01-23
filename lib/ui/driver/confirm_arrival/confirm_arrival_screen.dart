import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/confirm_arrival/confirm_arrival_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/confirm_arrival/confirm_arrival_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/confirm_arrival/confirm_arrival_state.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/services/driver/customer_missing_service.dart';
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

  const ConfirmArrivalScreen({
    super.key,
    required this.session,
    this.preventBackNavigation = false,
    this.showHandoverOnLoad = false,
  });

  @override
  State<ConfirmArrivalScreen> createState() => _ConfirmArrivalScreenState();
}

class _ConfirmArrivalScreenState extends State<ConfirmArrivalScreen> {
  bool _showHandoverButtons = false;
  final GlobalKey<HandoverButtonsSectionState> _handoverButtonsKey =
      GlobalKey<HandoverButtonsSectionState>();

  @override
  void initState() {
    super.initState();
    _showHandoverButtons = widget.showHandoverOnLoad;
  }

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

            final scaffoldContent = Scaffold(
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
                                  await CustomerMissingService
                                      .handleCustomerMissing(
                                    context: context,
                                    sessionId: widget.session.id,
                                    onSuccess: () {
                                      // Any additional success handling can be added here
                                    },
                                  );
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
