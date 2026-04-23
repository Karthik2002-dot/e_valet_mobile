/// Parses user-entered card lists: commas, spaces, semicolons, newlines.
/// Card numbers must be positive integers in \[1, 99999\].
({List<int> numbers, String? error}) parseCardNumbersInput(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return (numbers: <int>[], error: null);
  }

  final tokens = trimmed
      .split(RegExp(r'[\s,;]+'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  final seen = <int>{};
  final out = <int>[];

  for (final t in tokens) {
    if (!RegExp(r'^\d+$').hasMatch(t)) {
      return (
        numbers: <int>[],
        error: 'Invalid card number: $t',
      );
    }
    final n = int.parse(t);
    if (n < 1 || n > 99999) {
      return (
        numbers: <int>[],
        error: 'Card number out of range (1–99999): $t',
      );
    }
    if (seen.add(n)) {
      out.add(n);
    }
  }

  out.sort();
  return (numbers: out, error: null);
}

/// comma-separated preview for dialogs / tiles.
String formatCardNumbersForEditing(List<int> numbers) => numbers.join(', ');
