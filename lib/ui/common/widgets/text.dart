import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

class TextComponent extends StatefulWidget {
  const TextComponent({
    super.key,
    required this.labelText,
    this.fontSize,
    this.height,
    this.color,
    this.fontWeight,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.textBackgroundColor,
    this.fontStyle,
    this.isTranslateRequired,
    this.letterSpacing,
    this.wordSpacing,
    this.textDecoration,
    this.textDecorationColor,
    this.textDecorationStyle,
    this.textDecorationThickness,
    this.shadows,
    this.softWrap,
  });

  final String labelText;
  final double? fontSize;
  final double? height;
  final Color? color;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final Color? textBackgroundColor;
  final FontStyle? fontStyle;
  final bool? isTranslateRequired;
  final double? letterSpacing;
  final double? wordSpacing;
  final TextDecoration? textDecoration;
  final Color? textDecorationColor;
  final TextDecorationStyle? textDecorationStyle;
  final double? textDecorationThickness;
  final List<Shadow>? shadows;
  final bool? softWrap;

  @override
  State<TextComponent> createState() => _TextComponentState();
}

class _TextComponentState extends State<TextComponent> {
  /// Translate text if translation service is available
  /// For now, this returns the text as-is
  /// TODO: Implement translation service integration when available
  String _translateText(String text) {
    // Placeholder for future translation implementation
    // Example: return LanguageService.translate(text);
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final shouldTranslate = widget.isTranslateRequired ?? false;
    final displayText =
        shouldTranslate ? _translateText(widget.labelText) : widget.labelText;

    // Check if running on iOS
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Text(
        displayText,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        textAlign: widget.textAlign,
        softWrap: widget.softWrap,
        style: GoogleFonts.jost(
          height: widget.height,
          fontSize: widget.fontSize,
          color: widget.color,
          fontWeight: widget.fontWeight,
          backgroundColor: widget.textBackgroundColor,
          fontStyle: widget.fontStyle,
          letterSpacing: widget.letterSpacing,
          wordSpacing: widget.wordSpacing,
          decoration: widget.textDecoration,
          decorationColor: widget.textDecorationColor,
          decorationStyle: widget.textDecorationStyle,
          decorationThickness: widget.textDecorationThickness,
          shadows: widget.shadows,
        ),
      );
    }

    // Default Material Design Text for other platforms
    return Text(
      displayText,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      textAlign: widget.textAlign,
      softWrap: widget.softWrap,
      style: GoogleFonts.jost(
        height: widget.height,
        fontSize: widget.fontSize,
        color: widget.color,
        fontWeight: widget.fontWeight,
        backgroundColor: widget.textBackgroundColor,
        fontStyle: widget.fontStyle,
        letterSpacing: widget.letterSpacing,
        wordSpacing: widget.wordSpacing,
        decoration: widget.textDecoration,
        decorationColor: widget.textDecorationColor,
        decorationStyle: widget.textDecorationStyle,
        decorationThickness: widget.textDecorationThickness,
        shadows: widget.shadows,
      ),
    );
  }
}
