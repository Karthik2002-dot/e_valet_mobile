import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/models/driver/session/pass_available_driver.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/driver/retrival_request/retrival_widgets/driver_card.dart';
import 'package:niloufer_valet_mobile/ui/driver/retrival_request/retrival_widgets/session_card.dart';

class RetrievalRequestSheet extends StatelessWidget {
  final AssignedSession? session;
  final String? message;
  final bool isLoading;
  final bool isAcceptLoading;
  final VoidCallback? onAccept;

  // Pass-to-driver section
  final List<PassAvailableDriver> availableDrivers;
  final bool isDriversLoading;
  final String? passingDriverId;
  final void Function(PassAvailableDriver driver)? onPassToDriver;

  const RetrievalRequestSheet({
    super.key,
    this.session,
    this.message,
    this.isLoading = false,
    this.isAcceptLoading = false,
    this.onAccept,
    this.availableDrivers = const [],
    this.isDriversLoading = false,
    this.passingDriverId,
    this.onPassToDriver,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTranslationsNotifier>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    const horizontalPadding = 16.0;
    const verticalPadding = 12.0;
    final maxSheetHeight = screenHeight * 0.88;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            right: horizontalPadding,
            top: verticalPadding,
            bottom: verticalPadding + bottomPadding,
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow10,
                  blurRadius: 12,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Scrollable content — shrinks to fit; scrolls when content
                // exceeds the maxHeight cap on the parent Container.
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Drag handle (centred)
                        Center(
                          child: Container(
                            width: screenWidth * 0.16,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.greyLight,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        TextComponent(
                          labelText: t.get(TextConstants.retrievalRequest),
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                        const SizedBox(height: 12),
                        if (isLoading) ...[
                          const Center(child: CircularProgressIndicator()),
                          const SizedBox(height: 16),
                        ] else if (message != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: TextComponent(
                              labelText: message!,
                              textAlign: TextAlign.center,
                              fontSize: screenWidth * 0.04,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ] else if (session != null) ...[
                          SessionCard(session: session!, onAccept: onAccept),
                        ] else ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: TextComponent(
                              labelText: t.get(
                                  TextConstants.noActiveRetrievalRequests),
                              textAlign: TextAlign.center,
                              fontSize: screenWidth * 0.04,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],

                        // Pass-to-driver section — only shown when a session is active
                        if (session != null) ...[
                          const SizedBox(height: 4),
                          _PassToDriverSection(
                            screenWidth: screenWidth,
                            isDriversLoading: isDriversLoading,
                            drivers: availableDrivers,
                            passingDriverId: passingDriverId,
                            onPassToDriver: onPassToDriver,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Accept / Collect Keys button
                if (session != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isAcceptLoading
                            ? null
                            : (onAccept ?? () => Navigator.of(context).pop()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isAcceptLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.black),
                                ),
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextComponent(
                                      labelText: t.getByKey('acceptRequest',
                                          TextConstants.acceptRequest),
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.black,
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: screenWidth * 0.06,
                                      color: AppColors.black,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pass-to-driver section widget
// ---------------------------------------------------------------------------

class _PassToDriverSection extends StatelessWidget {
  final double screenWidth;
  final bool isDriversLoading;
  final List<PassAvailableDriver> drivers;
  final String? passingDriverId;
  final void Function(PassAvailableDriver driver)? onPassToDriver;

  const _PassToDriverSection({
    required this.screenWidth,
    required this.isDriversLoading,
    required this.drivers,
    required this.passingDriverId,
    required this.onPassToDriver,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(color: AppColors.divider, height: 24),

        // Section header
        Row(
          children: [
            const Icon(Icons.swap_horiz_rounded,
                size: 18, color: AppColors.mutedText),
            const SizedBox(width: 6),
            Text(
              'Pass to Another Driver',
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (isDriversLoading) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ] else if (drivers.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No other drivers available at this time.',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: AppColors.mutedText,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ] else ...[
          // Two-column grid — build rows of two manually so the grid is
          // non-scrollable and fits inside the parent SingleChildScrollView.
          for (int i = 0; i < drivers.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: DriverCard(
                      driver: drivers[i],
                      screenWidth: screenWidth,
                      isPassing: passingDriverId == drivers[i].userId,
                      isAnyPassing: passingDriverId != null,
                      onTap: onPassToDriver != null
                          ? () => onPassToDriver!(drivers[i])
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Second card — or an empty spacer if count is odd
                  if (i + 1 < drivers.length)
                    Expanded(
                      child: DriverCard(
                        driver: drivers[i + 1],
                        screenWidth: screenWidth,
                        isPassing: passingDriverId == drivers[i + 1].userId,
                        isAnyPassing: passingDriverId != null,
                        onTap: onPassToDriver != null
                            ? () => onPassToDriver!(drivers[i + 1])
                            : null,
                      ),
                    )
                  else
                    const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
