import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/models/translations/language.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/services/translations/language_cache.dart';
import 'package:niloufer_valet_mobile/services/translations/translations_cache.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:pull_down_button/pull_down_button.dart';

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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        width: widget.iconSize,
        height: widget.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    if (_languages.isEmpty) {
      return SizedBox(
        width: widget.iconSize,
        height: widget.iconSize,
        child: Image.asset(
          'assets/images/language.png',
          fit: BoxFit.contain,
          color: AppColors.white,
        ),
      );
    }

    return PullDownButton(
      useRootNavigator: true,
      itemBuilder: (context) {
        final items = <PullDownMenuEntry>[];
        var isFirst = true;
        for (final lang in _languages) {
          if (!isFirst) {
            items.add(const PullDownMenuDivider());
          } else {
            isFirst = false;
          }
          items.add(
            PullDownMenuItem.selectable(
              title: lang.nativeName,
              selected: _selectedLanguage == lang,
              onTap: () async {
                if (_selectedLanguage == lang) return;
                final previousLanguage = _selectedLanguage;
                setState(() => _selectedLanguage = lang);
                try {
                  await TranslationsCache()
                      .setSelectedLanguageAndFetch(lang.code);
                  if (mounted) {
                    context.read<AppTranslationsNotifier>().load();
                  }
                } catch (_) {
                  if (!mounted) return;
                  setState(() => _selectedLanguage = previousLanguage);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Failed to change language. Please try again.'),
                    ),
                  );
                }
              },
            ),
          );
        }
        return items;
      },
      buttonBuilder: (context, showMenu) {
        return IconButton(
          onPressed: showMenu,
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
      },
    );
  }
}
