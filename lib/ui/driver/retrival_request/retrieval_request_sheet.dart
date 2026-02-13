import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/driver/retrival_request/retrival_widgets/session_card.dart';

class RetrievalRequestSheet extends StatelessWidget {
  final AssignedSession? session;
  final String? message;
  final bool isLoading;
  final bool isAcceptLoading;
  final VoidCallback? onAccept;

  const RetrievalRequestSheet({
    super.key,
    this.session,
    this.message,
    this.isLoading = false,
    this.isAcceptLoading = false,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
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
                Container(
                  width: screenWidth * 0.16,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                TextComponent(
                  labelText: TextConstants.retrievalRequest,
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
                      labelText: TextConstants.noActiveRetrievalRequests,
                      textAlign: TextAlign.center,
                      fontSize: screenWidth * 0.04,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
                if (session != null) ...[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  TextComponent(
                    labelText: TextConstants.pressBelowToAcceptRequest,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.12,
                    width: double.infinity,
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
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.black),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextComponent(
                                  labelText: TextConstants.acceptRequest,
                                  fontSize: screenWidth * 0.055,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  size: screenWidth * 0.07,
                                  color: AppColors.black,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
