import 'dart:math';

class TextNormalizer {
  TextNormalizer._();

  static final RegExp _parenRegex = RegExp(r'\([^)]*\)');
  static final RegExp _punctuationRegex =
      RegExp(r'''[.,;:!?'"()\[\]{}<>\/\\\-–—_]+''');
  static final RegExp _multiSpaceRegex = RegExp(r'\s+');

  static const Set<String> _fillerWords = {
    'cac',
    'nhung',
    'mot',
    'cai',
    'chiec',
    'su',
    'viec',
    'la',
    'cua',
    'trong',
    'cho',
    'the',
    'a',
    'an',
  };

  /// Normalizes text for term and keyword matching:
  /// - Lowercases
  /// - Replaces punctuation/hyphens with spaces
  /// - Collapses multiple spaces and trims
  static String normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(_punctuationRegex, ' ')
        .replaceAll(_multiSpaceRegex, ' ')
        .trim();
  }

  /// Strips parenthetical explanations like "(ABS)" or "(tầng thu nhận)" before normalizing.
  static String normalizeWithoutParens(String input) {
    return normalize(input.replaceAll(_parenRegex, ' '));
  }

  /// Strips Vietnamese diacritics for lenient fallback comparison.
  static String stripVietnameseDiacritics(String input) {
    const withDiacritics =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ'
        'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
    const withoutDiacritics =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd'
        'AAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';

    var result = input;
    for (int i = 0; i < withDiacritics.length; i++) {
      result = result.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return result;
  }

  static List<String> _contentTokens(String strippedNormalized) {
    final tokens = strippedNormalized
        .split(' ')
        .where((t) => t.isNotEmpty)
        .toList();
    final filtered = tokens.where((t) => !_fillerWords.contains(t)).toList();
    return filtered.isNotEmpty ? filtered : tokens;
  }

  static double _levenshteinSimilarity(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    if (a == b) return 1.0;

    final m = a.length;
    final n = b.length;
    var prev = List<int>.generate(n + 1, (j) => j);
    var curr = List<int>.filled(n + 1, 0);

    for (int i = 1; i <= m; i++) {
      curr[0] = i;
      for (int j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = min(
          min(curr[j - 1] + 1, prev[j] + 1),
          prev[j - 1] + cost,
        );
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }

    final maxLen = max(m, n);
    return 1.0 - (prev[n] / maxLen);
  }

  static double _tokenDiceSimilarity(List<String> a, List<String> b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    final setA = a.toSet();
    final setB = b.toSet();
    int matches = 0;
    for (final ta in setA) {
      if (setB.contains(ta)) {
        matches++;
      } else {
        // Allow close single-word match (e.g. minor typo)
        for (final tb in setB) {
          if (ta.length >= 3 &&
              tb.length >= 3 &&
              _levenshteinSimilarity(ta, tb) >= 0.8) {
            matches++;
            break;
          }
        }
      }
    }
    return (2.0 * matches) / (setA.length + setB.length);
  }

  /// Checks if user term translation matches or is close enough to any accepted variant.
  static bool isTermMatch(String userAnswer, List<String> acceptedAnswers) {
    final normUser = normalizeWithoutParens(userAnswer);
    if (normUser.isEmpty) return false;
    final strippedUser = normalize(stripVietnameseDiacritics(normUser));
    final userTokens = _contentTokens(strippedUser);

    for (final rawAns in acceptedAnswers) {
      final variants = <String>{
        normalize(rawAns),
        normalizeWithoutParens(rawAns),
      };

      for (final normAns in variants) {
        if (normAns.isEmpty) continue;
        if (normUser == normAns) return true;

        final strippedAns = normalize(stripVietnameseDiacritics(normAns));
        if (strippedUser.length >= 3 && strippedUser == strippedAns) {
          return true;
        }

        // Character-level similarity (handles minor typos/diacritics/spacing)
        if (strippedUser.length >= 4 &&
            _levenshteinSimilarity(strippedUser, strippedAns) >= 0.78) {
          return true;
        }

        // Token-level similarity (handles filler words, word order, or near-synonym phrasing)
        final ansTokens = _contentTokens(strippedAns);
        if (userTokens.isNotEmpty && ansTokens.isNotEmpty) {
          final dice = _tokenDiceSimilarity(userTokens, ansTokens);
          if (dice >= 0.68) {
            return true;
          }
          // If user typed a core phrase contained inside a longer answer (at least 2 content words)
          if (userTokens.length >= 2 &&
              userTokens.every((t) => ansTokens.contains(t)) &&
              userTokens.length / ansTokens.length >= 0.5) {
            return true;
          }
        }
      }
    }
    return false;
  }

  static String formatDuration(int totalSeconds) {
    final safe = totalSeconds < 0 ? 0 : totalSeconds;
    final mins = safe ~/ 60;
    final secs = safe % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
