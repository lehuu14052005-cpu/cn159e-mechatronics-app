class VocabularyItem {
  final String id;
  final String chapterId;
  final String term;
  final String partOfSpeech;
  final String phonetic;
  final String vietnamese;
  final List<String> acceptedTranslations;
  final String exampleEn;
  final String exampleVi;
  final List<String> relatedPhrases;
  final bool isSupplemental;

  const VocabularyItem({
    required this.id,
    required this.chapterId,
    required this.term,
    required this.partOfSpeech,
    required this.phonetic,
    required this.vietnamese,
    required this.acceptedTranslations,
    required this.exampleEn,
    required this.exampleVi,
    required this.relatedPhrases,
    this.isSupplemental = false,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      id: json['id'] as String,
      chapterId: json['chapterId'] as String,
      term: json['term'] as String,
      partOfSpeech: json['partOfSpeech'] as String? ?? 'noun',
      phonetic: json['phonetic'] as String? ?? '',
      vietnamese: json['vietnamese'] as String,
      acceptedTranslations: List<String>.from(
        json['acceptedTranslations'] as List? ?? [json['vietnamese']],
      ),
      exampleEn: json['exampleEn'] as String? ?? '',
      exampleVi: json['exampleVi'] as String? ?? '',
      relatedPhrases: List<String>.from(json['relatedPhrases'] as List? ?? []),
      isSupplemental: json['isSupplemental'] as bool? ?? false,
    );
  }

  List<String> get allAcceptedVietnamese => {
        vietnamese,
        ...acceptedTranslations,
      }.toList();
}

class VocabularyProgress {
  final bool isLearned;
  final bool isDifficult;
  final bool needsReview;
  final int reviewCount;

  const VocabularyProgress({
    this.isLearned = false,
    this.isDifficult = false,
    this.needsReview = false,
    this.reviewCount = 0,
  });

  VocabularyProgress copyWith({
    bool? isLearned,
    bool? isDifficult,
    bool? needsReview,
    int? reviewCount,
  }) {
    return VocabularyProgress(
      isLearned: isLearned ?? this.isLearned,
      isDifficult: isDifficult ?? this.isDifficult,
      needsReview: needsReview ?? this.needsReview,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'isLearned': isLearned,
        'isDifficult': isDifficult,
        'needsReview': needsReview,
        'reviewCount': reviewCount,
      };

  factory VocabularyProgress.fromJson(Map<String, dynamic> json) {
    return VocabularyProgress(
      isLearned: json['isLearned'] as bool? ?? false,
      isDifficult: json['isDifficult'] as bool? ?? false,
      needsReview: json['needsReview'] as bool? ?? false,
      reviewCount: json['reviewCount'] as int? ?? 0,
    );
  }
}
