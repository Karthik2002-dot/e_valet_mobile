import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/translations/language.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

/// Popup dialog for language selection. Does not close on tap outside;
/// user must select a language or tap Close.
class LanguagePopupDialog extends StatelessWidget {
  const LanguagePopupDialog({
    super.key,
    required this.languages,
    required this.selectedLanguage,
    required this.onLanguageSelected,
    required this.onClose,
  });

  final List<Language> languages;
  final Language? selectedLanguage;
  final Future<void> Function(Language lang) onLanguageSelected;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 320,
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title row with Close button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  TextComponent(
                    labelText: TextConstants.language,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, color: AppColors.black),
                    tooltip: TextConstants.close,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Language list
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                itemCount: languages.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  final isSelected = selectedLanguage == lang;
                  return ListTile(
                    title: TextComponent(
                      labelText: lang.nativeName,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: AppColors.black,
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check,
                            color: AppColors.secondary,
                            size: 22,
                          )
                        : null,
                    onTap: () async {
                      await onLanguageSelected(lang);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
