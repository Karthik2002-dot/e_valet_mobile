import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/guidelines/guidelines_main_title.dart';
import 'package:niloufer_valet_mobile/ui/guidelines/guidelines_section.dart';
import 'package:niloufer_valet_mobile/ui/help_support/contact_card.dart';

/// Shared Help screen for both Driver and Operator roles.
/// Accessible from the overflow menu (driver) and side drawer (operator).
/// Same content for both roles.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const List<ContactInfo> _contacts = [
    ContactInfo(
      name: 'Manish',
      team: 'GPS Team',
      phone: '+91-7207547219',
    ),
    ContactInfo(
      name: 'Sai Charan',
      team: 'Niloufer Banjara Team',
      phone: '+91-9676511973',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GuidelinesMainTitle(title: TextConstants.help),
                    const SizedBox(height: 24),
                    GuidelinesSection(
                      title: TextConstants.helpContactSupport,
                      icon: Icons.support_agent,
                      items: const [],
                    ),
                    const SizedBox(height: 12),
                    ..._contacts.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: ContactCard(contact: c),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
