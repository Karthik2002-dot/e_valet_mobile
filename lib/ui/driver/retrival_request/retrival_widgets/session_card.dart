import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class SessionCard extends StatelessWidget {
  final AssignedSession session;
  final VoidCallback? onAccept;

  const SessionCard({super.key, required this.session, this.onAccept});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow10,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: Stack(
                  children: [
                    Image(
                      image: session.photoUrl != null
                          ? NetworkImage(session.photoUrl!)
                          : const AssetImage('assets/images/car.png')
                              as ImageProvider,
                      width: double.infinity,
                      height: screenWidth * 0.35,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/car.png',
                          width: double.infinity,
                          height: screenWidth * 0.35,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    if (session.hasPhotos)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: AppColors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.directions_car,
                          size: 20,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextComponent(
                                labelText: TextConstants.badgeNumber,
                                fontSize: screenWidth * 0.035,
                                color: AppColors.grey,
                              ),
                              const SizedBox(height: 4),
                              TextComponent(
                                labelText: session.cardNumber.toString(),
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      color: AppColors.greyLight,
                      thickness: 1,
                      height: 1,
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.badge,
                              size: 20,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextComponent(
                                labelText:
                                    '${TextConstants.parkedBy} ${session.parkedBy?.name ?? TextConstants.unknown}',
                                fontSize: screenWidth * 0.04,
                                color: AppColors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.phone,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
