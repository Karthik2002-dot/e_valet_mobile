import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

/// Shared Guidelines screen for both Driver and Operator roles.
/// Accessible from the overflow menu (driver) and side drawer (operator).
class GuidelinesScreen extends StatelessWidget {
  const GuidelinesScreen({super.key});

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
                    _GuidelinesMainTitle(title: TextConstants.guidelines),
                    const SizedBox(height: 24),
                    _GuidelinesSection(
                      title: 'How to Park',
                      icon: Icons.local_parking,
                      items: [
                        'English',
                        '1. Give QR valet card to customer',
                        '2. Sit in car and scan QR in app',
                        '3. Park the vehicle',
                        '4. Take clear photo of car & number plate',
                        '5. Enter correct parking location (B1/B2/B3)',
                        '6. Press Submit',
                        'हिंदी',
                        '1. ग्राहक को QR वैलेट कार्ड दें',
                        '2. कार में बैठकर ऐप से QR स्कैन करें',
                        '3. गाड़ी पार्क करें',
                        '4. कार और नंबर प्लेट की साफ फोटो लें.',
                        '5. सही पार्किंग लोकेशन डालें (B1/B2/B3)',
                        '6. "Submit" दबाएं',
                        'తెలుగు',
                        '1. కస్టమర్ కు QR వాలెట్ కార్డ్ ఇవ్వండి',
                        '2. కారులో కూర్చుని యాప్ లో QR స్కాన్ చేయండి',
                        '3. వాహనాన్ని పార్క్ చేయండి',
                        '4. కారు & నంబర్ ప్లేట్ స్పష్టమైన ఫోటో తీయండి',
                        '5. సరైన పార్కింగ్ లొకేషన్ నమోదు చేయండి (B1/B2/B3)',
                        '6. "Submit" నొక్కండి',
                      ],
                    ),
                    const SizedBox(height: 20),
                    _GuidelinesSection(
                      title: 'How to Handover',
                      icon: Icons.handshake,
                      items: [
                        'English',
                        '1. Accept request in app',
                        '2. Collect keys from supervisor',
                        '3. Bring car to pickup area',
                        '4. Tap "Confirm Arrival"',
                        '5. Give car & keys to customer',
                        '6. Collect QR valet card back',
                        'हिंदी',
                        '1. ऐप में रिक्वेस्ट Accept करें',
                        '2. सुपरवाइज़र से चाबियां लें',
                        '3. गाड़ी को पिकअप एरिया में लाएं',
                        '4. "Confirm Arrival" दबाएं',
                        '5. ग्राहक को गाड़ी और चाबी दें',
                        '6. ग्राहक से QR कार्ड वापस लें',
                        'తెలుగు',
                        '1. యాప్ లో రిక్వెస్ట్ Accept చేయండి',
                        '2. సూపర్వైజర్ వద్ద నుంచి కీలు తీసుకోండి',
                        '3. కారును పికప్ ప్రాంతానికి తీసుకురండి',
                        '4. "Confirm Arrival" నొక్కండి',
                        '5. కస్టమర్ కు కారు మరియు కీలు ఇవ్వండి',
                        '6. QR వాలెట్ కార్డ్ తిరిగి తీసుకోండి',
                      ],
                    ),
                    const SizedBox(height: 20),
                    _GuidelinesSection(
                      title: 'Operator Responsibilities',
                      icon: Icons.admin_panel_settings,
                      items: [
                        'English',
                        '1. Monitor all parking & car handover requests',
                        '2. Assign nearest available driver',
                        '3. Ensure drivers accept and complete tasks',
                        '4. Handle missed or manual requests',
                        '5. Support drivers in case of issues',
                        'हिंदी',
                        '1. सभी पार्किंग और गाड़ी देने की रिक्वेस्ट देखें',
                        '2. नजदीकी उपलब्ध ड्राइवर को असाइन करें',
                        '3. ड्राइवर रिक्वेस्ट Accept करे और काम पूरा करे यह देखें',
                        '4. मिस या मैनुअल रिक्वेस्ट संभालें',
                        '5. समस्या होने पर ड्राइवर की मदद करें',
                        'తెలుగు',
                        '1. అన్ని పార్కింగ్ మరియు కారు ఇవ్వడం రిక్వెస్ట్లను చూడండి',
                        '2. దగ్గరలో ఉన్న డ్రైవర్ కు అసైన్ చేయండి',
                        '3. డ్రైవర్ రిక్వెస్ట్ Accept చేసి పని పూర్తి చేశాడో చూడండి',
                        '4. మిస్ అయిన లేదా మాన్యువల్ రిక్వెస్ట్లను నిర్వహించండి',
                        '5. సమస్యలు వచ్చినప్పుడు డ్రైవర్లకు సహాయం చేయండి',
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}

/// Main title with accent bar and subtle background.
class _GuidelinesMainTitle extends StatelessWidget {
  final String title;

  const _GuidelinesMainTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
      ),
      child: TextComponent(
        labelText: title,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }
}

/// Language header labels that get bold + underline styling.
const _languageHeaders = {
  'English',
  'हिंदी',
  'తెలుగు',
};

/// Section header with icon and accent styling.
class _GuidelinesSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;

  const _GuidelinesSection({
    required this.title,
    required this.items,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primarySoft,
                AppColors.primarySoft.withOpacity(0.6),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextComponent(
                  labelText: title,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...items.map((item) {
          final isLanguageHeader = _languageHeaders.contains(item);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextComponent(
              labelText: item,
              fontSize: 14,
              fontWeight: isLanguageHeader ? FontWeight.bold : FontWeight.w400,
              color: isLanguageHeader ? AppColors.primaryDark : AppColors.black,
              textDecoration:
                  isLanguageHeader ? TextDecoration.underline : null,
              textDecorationThickness: isLanguageHeader ? 2.0 : null,
              textDecorationColor:
                  isLanguageHeader ? AppColors.primaryDark : null,
            ),
          );
        }),
      ],
    );
  }
}
