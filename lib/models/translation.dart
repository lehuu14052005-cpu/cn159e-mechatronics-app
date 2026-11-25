class KeyTermPair {
  final String en;
  final String vi;

  const KeyTermPair({required this.en, required this.vi});

  factory KeyTermPair.fromJson(Map<String, dynamic> json) {
    return KeyTermPair(
      en: json['en'] as String,
      vi: json['vi'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'en': en, 'vi': vi};
}

class ScoringKeyword {
  final String term;
  final List<String> alternatives;
  final double weight;

  const ScoringKeyword({
    required this.term,
    required this.alternatives,
    required this.weight,
  });

  factory ScoringKeyword.fromJson(Map<String, dynamic> json) {
    return ScoringKeyword(
      term: json['term'] as String,
      alternatives: List<String>.from(json['alternatives'] as List? ?? []),
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

class TranslationParagraph {
  final String id;
  final String chapterId;
  final String direction; // en_vi or vi_en
  final String title;
  final String sourceText;
  final String sampleTranslation;
  final List<KeyTermPair> keyTerms;
  final List<String> keyPhrases;
  final List<ScoringKeyword> keywordsForScoring;
  final String grammarOrTranslationHints;
  final String importantNotes;

  const TranslationParagraph({
    required this.id,
    required this.chapterId,
    required this.direction,
    required this.title,
    required this.sourceText,
    required this.sampleTranslation,
    required this.keyTerms,
    required this.keyPhrases,
    required this.keywordsForScoring,
    required this.grammarOrTranslationHints,
    required this.importantNotes,
  });

  factory TranslationParagraph.fromJson(Map<String, dynamic> json) {
    return TranslationParagraph(
      id: json['id'] as String,
      chapterId: json['chapterId'] as String,
      direction: json['direction'] as String,
      title: json['title'] as String,
      sourceText: json['sourceText'] as String,
      sampleTranslation: json['sampleTranslation'] as String,
      keyTerms: (json['keyTerms'] as List? ?? [])
          .map((e) => KeyTermPair.fromJson(e as Map<String, dynamic>))
          .toList(),
      keyPhrases: List<String>.from(json['keyPhrases'] as List? ?? []),
      keywordsForScoring: (json['keywordsForScoring'] as List? ?? [])
          .map((e) => ScoringKeyword.fromJson(e as Map<String, dynamic>))
          .toList(),
      grammarOrTranslationHints:
          json['grammarOrTranslationHints'] as String? ?? '',
      importantNotes: json['importantNotes'] as String? ?? '',
    );
  }
}

class TranslationEvaluation {
  final double estimatedScore; // 0.0 to 2.5
  final double keywordCoverage; // 0.0 to 1.0
  final double completenessRatio; // 0.0 to 1.0
  final List<String> matchedKeywords;
  final List<String> missedKeywords;
  final String feedback;
  final bool isEstimated;

  const TranslationEvaluation({
    required this.estimatedScore,
    required this.keywordCoverage,
    required this.completenessRatio,
    required this.matchedKeywords,
    required this.missedKeywords,
    required this.feedback,
    this.isEstimated = true,
  });

  Map<String, dynamic> toJson() => {
        'estimatedScore': estimatedScore,
        'keywordCoverage': keywordCoverage,
        'completenessRatio': completenessRatio,
        'matchedKeywords': matchedKeywords,
        'missedKeywords': missedKeywords,
        'feedback': feedback,
        'isEstimated': isEstimated,
      };

  factory TranslationEvaluation.fromJson(Map<String, dynamic> json) {
    return TranslationEvaluation(
      estimatedScore: (json['estimatedScore'] as num).toDouble(),
      keywordCoverage: (json['keywordCoverage'] as num?)?.toDouble() ?? 0.0,
      completenessRatio: (json['completenessRatio'] as num?)?.toDouble() ?? 0.0,
      matchedKeywords:
          List<String>.from(json['matchedKeywords'] as List? ?? []),
      missedKeywords: List<String>.from(json['missedKeywords'] as List? ?? []),
      feedback: json['feedback'] as String? ?? '',
      isEstimated: json['isEstimated'] as bool? ?? true,
    );
  }
}

class TranslationHistoryItem {
  final String id;
  final String paragraphId;
  final String chapterId;
  final String direction;
  final String title;
  final String userAnswer;
  final double estimatedScore;
  final int timestampMs;

  const TranslationHistoryItem({
    required this.id,
    required this.paragraphId,
    required this.chapterId,
    required this.direction,
    required this.title,
    required this.userAnswer,
    required this.estimatedScore,
    required this.timestampMs,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'paragraphId': paragraphId,
        'chapterId': chapterId,
        'direction': direction,
        'title': title,
        'userAnswer': userAnswer,
        'estimatedScore': estimatedScore,
        'timestampMs': timestampMs,
      };

  factory TranslationHistoryItem.fromJson(Map<String, dynamic> json) {
    return TranslationHistoryItem(
      id: json['id'] as String,
      paragraphId: json['paragraphId'] as String,
      chapterId: json['chapterId'] as String,
      direction: json['direction'] as String,
      title: json['title'] as String,
      userAnswer: json['userAnswer'] as String,
      estimatedScore: (json['estimatedScore'] as num).toDouble(),
      timestampMs: json['timestampMs'] as int,
    );
  }
}
