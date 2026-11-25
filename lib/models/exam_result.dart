import 'translation.dart';

class McqReviewItem {
  final String questionId;
  final String chapterId;
  final String questionText;
  final List<String> displayOptions;
  final int correctDisplayIndex;
  final int? userDisplayIndex;
  final String explanation;
  final String readingReference;

  const McqReviewItem({
    required this.questionId,
    required this.chapterId,
    required this.questionText,
    required this.displayOptions,
    required this.correctDisplayIndex,
    required this.userDisplayIndex,
    required this.explanation,
    required this.readingReference,
  });

  bool get isCorrect => userDisplayIndex == correctDisplayIndex;
  bool get isBlank => userDisplayIndex == null;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'chapterId': chapterId,
        'questionText': questionText,
        'displayOptions': displayOptions,
        'correctDisplayIndex': correctDisplayIndex,
        'userDisplayIndex': userDisplayIndex,
        'explanation': explanation,
        'readingReference': readingReference,
      };

  factory McqReviewItem.fromJson(Map<String, dynamic> json) {
    return McqReviewItem(
      questionId: json['questionId'] as String,
      chapterId: json['chapterId'] as String,
      questionText: json['questionText'] as String,
      displayOptions: List<String>.from(json['displayOptions'] as List),
      correctDisplayIndex: json['correctDisplayIndex'] as int,
      userDisplayIndex: json['userDisplayIndex'] as int?,
      explanation: json['explanation'] as String? ?? '',
      readingReference: json['readingReference'] as String? ?? '',
    );
  }
}

class TermReviewItem {
  final String termId;
  final String chapterId;
  final String englishTerm;
  final String userAnswer;
  final String primaryVietnamese;
  final List<String> acceptedTranslations;
  final bool isCorrect;

  const TermReviewItem({
    required this.termId,
    required this.chapterId,
    required this.englishTerm,
    required this.userAnswer,
    required this.primaryVietnamese,
    required this.acceptedTranslations,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() => {
        'termId': termId,
        'chapterId': chapterId,
        'englishTerm': englishTerm,
        'userAnswer': userAnswer,
        'primaryVietnamese': primaryVietnamese,
        'acceptedTranslations': acceptedTranslations,
        'isCorrect': isCorrect,
      };

  factory TermReviewItem.fromJson(Map<String, dynamic> json) {
    return TermReviewItem(
      termId: json['termId'] as String,
      chapterId: json['chapterId'] as String,
      englishTerm: json['englishTerm'] as String,
      userAnswer: json['userAnswer'] as String? ?? '',
      primaryVietnamese: json['primaryVietnamese'] as String,
      acceptedTranslations:
          List<String>.from(json['acceptedTranslations'] as List),
      isCorrect: json['isCorrect'] as bool,
    );
  }
}

class ExamResult {
  final String id;
  final int createdAtMs;
  final int durationSeconds;
  final bool autoSubmitted;

  final double part1Score; // / 2.5
  final double part2Score; // / 2.5
  final double part3Score; // / 2.5
  final double part4Score; // / 2.5
  final double totalScore; // / 10.0

  final int correctMcq;
  final int wrongMcq;
  final int blankMcq;
  final int correctTerms;
  final int wrongTerms;

  /// chapterId -> accuracy (0.0 to 1.0)
  final Map<String, double> chapterAccuracy;

  final List<McqReviewItem> mcqReviews;
  final List<TermReviewItem> termReviews;

  final String enViParagraphId;
  final String enViUserAnswer;
  final TranslationEvaluation enViEval;

  final String viEnParagraphId;
  final String viEnUserAnswer;
  final TranslationEvaluation viEnEval;

  const ExamResult({
    required this.id,
    required this.createdAtMs,
    required this.durationSeconds,
    required this.autoSubmitted,
    required this.part1Score,
    required this.part2Score,
    required this.part3Score,
    required this.part4Score,
    required this.totalScore,
    required this.correctMcq,
    required this.wrongMcq,
    required this.blankMcq,
    required this.correctTerms,
    required this.wrongTerms,
    required this.chapterAccuracy,
    required this.mcqReviews,
    required this.termReviews,
    required this.enViParagraphId,
    required this.enViUserAnswer,
    required this.enViEval,
    required this.viEnParagraphId,
    required this.viEnUserAnswer,
    required this.viEnEval,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAtMs': createdAtMs,
        'durationSeconds': durationSeconds,
        'autoSubmitted': autoSubmitted,
        'part1Score': part1Score,
        'part2Score': part2Score,
        'part3Score': part3Score,
        'part4Score': part4Score,
        'totalScore': totalScore,
        'correctMcq': correctMcq,
        'wrongMcq': wrongMcq,
        'blankMcq': blankMcq,
        'correctTerms': correctTerms,
        'wrongTerms': wrongTerms,
        'chapterAccuracy': chapterAccuracy,
        'mcqReviews': mcqReviews.map((e) => e.toJson()).toList(),
        'termReviews': termReviews.map((e) => e.toJson()).toList(),
        'enViParagraphId': enViParagraphId,
        'enViUserAnswer': enViUserAnswer,
        'enViEval': enViEval.toJson(),
        'viEnParagraphId': viEnParagraphId,
        'viEnUserAnswer': viEnUserAnswer,
        'viEnEval': viEnEval.toJson(),
      };

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    final rawChAcc = json['chapterAccuracy'] as Map<String, dynamic>? ?? {};
    return ExamResult(
      id: json['id'] as String,
      createdAtMs: json['createdAtMs'] as int,
      durationSeconds: json['durationSeconds'] as int,
      autoSubmitted: json['autoSubmitted'] as bool? ?? false,
      part1Score: (json['part1Score'] as num).toDouble(),
      part2Score: (json['part2Score'] as num).toDouble(),
      part3Score: (json['part3Score'] as num).toDouble(),
      part4Score: (json['part4Score'] as num).toDouble(),
      totalScore: (json['totalScore'] as num).toDouble(),
      correctMcq: json['correctMcq'] as int,
      wrongMcq: json['wrongMcq'] as int,
      blankMcq: json['blankMcq'] as int,
      correctTerms: json['correctTerms'] as int,
      wrongTerms: json['wrongTerms'] as int,
      chapterAccuracy:
          rawChAcc.map((k, v) => MapEntry(k, (v as num).toDouble())),
      mcqReviews: (json['mcqReviews'] as List)
          .map((e) => McqReviewItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      termReviews: (json['termReviews'] as List)
          .map((e) => TermReviewItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      enViParagraphId: json['enViParagraphId'] as String,
      enViUserAnswer: json['enViUserAnswer'] as String? ?? '',
      enViEval: TranslationEvaluation.fromJson(
          json['enViEval'] as Map<String, dynamic>),
      viEnParagraphId: json['viEnParagraphId'] as String,
      viEnUserAnswer: json['viEnUserAnswer'] as String? ?? '',
      viEnEval: TranslationEvaluation.fromJson(
          json['viEnEval'] as Map<String, dynamic>),
    );
  }
}
