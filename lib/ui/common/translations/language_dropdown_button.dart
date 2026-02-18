import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/translations/language.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/services/translations/language_cache.dart';
import 'package:niloufer_valet_mobile/services/translations/translations_cache.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/translations/language_popup_dialog.dart';

class LanguageDropdownButton extends StatefulWidget {
  final double iconSize;

  const LanguageDropdownButton({
    super.key,
    required this.iconSize,
  });

  @override
  State<LanguageDropdownButton> createState() => _LanguageDropdownButtonState();
}

class _LanguageDropdownButtonState extends State<LanguageDropdownButton> {
  /// Fixed size for loading and empty-state icon (same as refresh/loading indicator).
  static const double _staticIconSize = 24.0;

  List<Language> _languages = [];
  Language? _selectedLanguage;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchLanguages();
  }

  Future<void> _fetchLanguages() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final langs = await LanguageCache().getLanguages();
      if (!mounted) return;
      final savedCode = await TranslationsCache().getSelectedLanguageCode();
      Language? selected = langs.isEmpty
          ? null
          : langs.firstWhere((l) => l.isDefault, orElse: () => langs.first);
      if (savedCode != null && savedCode.isNotEmpty) {
        final match = langs.where((l) => l.code == savedCode).toList();
        if (match.isNotEmpty) selected = match.first;
      }
      if (mounted) {
        setState(() {
          _languages = langs;
          _selectedLanguage = selected;
        });
      }
    } catch (_) {
      // keep empty list
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  void _openLanguagePopup() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => LanguagePopupDialog(
        languages: _languages,
        selectedLanguage: _selectedLanguage,
        onLanguageSelected: (lang) async {
          if (_selectedLanguage == lang) return;
          final previousLanguage = _selectedLanguage;
          setState(() => _selectedLanguage = lang);
          try {
            await TranslationsCache().setSelectedLanguageAndFetch(lang.code);
            if (mounted) {
              context.read<AppTranslationsNotifier>().load();
            }
          } catch (_) {
            if (!mounted) return;
            setState(() => _selectedLanguage = previousLanguage);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Failed to change language. Please try again.',
                ),
              ),
            );
          }
        },
        onClose: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        width: _staticIconSize,
        height: _staticIconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    if (_languages.isEmpty) {
      return SizedBox(
        width: _staticIconSize,
        height: _staticIconSize,
        child: Image.asset(
          'assets/images/language.png',
          fit: BoxFit.contain,
          color: AppColors.white,
        ),
      );
    }

    return IconButton(
      onPressed: _openLanguagePopup,
      icon: SizedBox(
        width: widget.iconSize,
        height: widget.iconSize,
        child: Image.asset(
          'assets/images/language.png',
          fit: BoxFit.contain,
          color: AppColors.white,
        ),
      ),
    );
  }
}
