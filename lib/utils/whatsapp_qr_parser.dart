/// Parses WhatsApp share URLs or raw message text and extracts the card number.
///
/// Supports:
/// - Full URL: https://wa.me/918885035945?text=Send%20to%20connect%20Card%20%2367%20at%20...
/// - Raw text: "Send to connect Card #67 at Cafe Niloufer Premium Lounge - Banjara Hills 👉"
/// Returns the card number (e.g. 67) or null if not found.
int? tryParseCardNumberFromWhatsAppUrl(String url) {
  if (url.isEmpty) return null;
  try {
    String textToSearch = url.trim();
    // Only treat as URL if it looks like one (has scheme or wa.me or contains ?text=)
    if (url.contains('?') && (url.contains('text=') || url.contains('wa.me'))) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        // queryParameters is already decoded by Dart
        final textParam = uri.queryParameters['text'];
        if (textParam != null && textParam.isNotEmpty) {
          textToSearch = textParam;
        }
      }
    }
    // Decode in case of %23 for # in raw pasted/partial URL
    if (textToSearch.contains('%')) {
      try {
        textToSearch = Uri.decodeComponent(textToSearch);
      } catch (_) {}
    }
    // Match "Card #67" – allow normal # or full-width ＃ (U+FF03), optional spaces
    RegExpMatch? match =
        RegExp(r'Card\s*[#\uFF03]\s*(\d+)', caseSensitive: false)
            .firstMatch(textToSearch);
    if (match == null) {
      // Fallback: first digit sequence after "Card" (e.g. "Card No. 67", "Card 67")
      match = RegExp(r'Card\s*[^\d]*?(\d+)', caseSensitive: false)
          .firstMatch(textToSearch);
    }
    if (match == null) return null;
    return int.tryParse(match.group(1) ?? '');
  } catch (_) {
    return null;
  }
}
