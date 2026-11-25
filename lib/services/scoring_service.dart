import 'dart:math';

import '../core/constants/app_constants.dart';
import '../core/utils/text_normalizer.dart';
import '../data/repositories/content_repository.dart';
import '../models/exam.dart';
import '../models/exam_result.dart';
import '../models/translation.dart';

/// Optional AI scoring extension hook. App works 100% offline without it.
abstract class AiScoringAdapter {
  Future<TranslationEvaluation?> evaluateTranslation(
    TranslationParagraph paragraph,
    String userAnswer,
  );
}

class ScoringService {
  ScoringService._();

  /// Scores a paragraph translation offline using a rubric:
  /// - 70% weighted keyword & equivalent-term coverage
  /// - 30% completeness ratio (word-count similarity to sample translation)
  /// Result is capped at 2.5 and rounded to nearest 0.125 for clean /10 totals.
  static TranslationEvaluation evaluateTranslationOffline(
    TranslationParagraph paragraph,
    String userAnswer,
  ) {
    final trimmed = userAnswer.trim();
    if (trimmed.isEmpty) {
      return const TranslationEvaluation(
        estimatedScore: 0.0,
        keywordCoverage: 0.0,
        completenessRatio: 0.0,
        matchedKeywords: [],
        missedKeywords: [],
        feedback: 'Bạn chưa nhập bản dịch. Hãy đối chiếu với bản dịch mẫu bên dưới.',
        isEstimated: true,
      );
    }

    final normUser = TextNormalizer.normalize(trimmed);
    final strippedUser = TextNormalizer.stripVietnameseDiacritics(normUser);

    double totalWeight = 0.0;
    double matchedWeight = 0.0;
    final matched = <String>[];
    final missed = <String>[];

    for (final kw in paragraph.keywordsForScoring) {
      totalWeight += kw.weight;
      final candidates = [kw.term, ...kw.alternatives];
      double bestMatchRatio = 0.0;
      for (final c in candidates) {
        final normC = TextNormalizer.normalize(c);
        if (normC.isEmpty) continue;
        if (normUser.contains(normC)) {
          bestMatchRatio = 1.0;
          break;
        }
        final strippedC = TextNormalizer.stripVietnameseDiacritics(normC);
        if (strippedC.length >= 4 && strippedUser.contains(strippedC)) {
          bestMatchRatio = 1.0;
          break;
        }
        // Partial word-overlap for multi-word phrases (near-meaning credit)
        final cWords = strippedC.split(' ').where((w) => w.length >= 2).toList();
        if (cWords.length >= 2) {
          final hitCount = cWords.where((w) => strippedUser.contains(w)).length;
          final ratio = hitCount / cWords.length;
          if (ratio >= 0.6 && ratio > bestMatchRatio) {
            bestMatchRatio = ratio;
          }
        }
      }

      if (bestMatchRatio >= 0.6) {
        matchedWeight += kw.weight * bestMatchRatio;
        matched.add(kw.term);
      } else {
        missed.add(kw.term);
      }
    }

    final keywordCoverage =
        totalWeight > 0 ? (matchedWeight / totalWeight).clamp(0.0, 1.0) : 0.0;

    final userWords = normUser.split(' ').where((w) => w.isNotEmpty).length;
    final sampleWords = TextNormalizer.normalize(paragraph.sampleTranslation)
        .split(' ')
        .where((w) => w.isNotEmpty)
        .length;

    double completeness = 0.0;
    if (sampleWords > 0) {
      final ratio = userWords / sampleWords;
      if (ratio >= 0.65 && ratio <= 1.45) {
        completeness = 1.0;
      } else if (ratio < 0.65) {
        completeness = (ratio / 0.65).clamp(0.0, 1.0);
      } else {
        completeness = max(0.5, 1.0 - (ratio - 1.45) * 0.4);
      }
    }

    // Penalize very short non-answers
    final rawRatio = (keywordCoverage * 0.72) + (completeness * 0.28);
    final rawScore = (rawRatio * AppConstants.part3MaxScore).clamp(0.0, 2.5);
    // Round to nearest 0.125
    final roundedScore = ((rawScore * 8).round() / 8.0).clamp(0.0, 2.5);

    final feedbackBuffer = StringBuffer();
    feedbackBuffer.write(
      'Điểm ước lượng theo rubric (${(keywordCoverage * 100).round()}% từ khóa chuyên ngành, '
      '${(completeness * 100).round()}% độ đầy đủ). ',
    );
    if (missed.isEmpty) {
      feedbackBuffer.write('Bản dịch bao quát tốt các thuật ngữ và ý chính.');
    } else {
      feedbackBuffer.write(
        'Nên bổ sung/đối chiếu lại các ý: ${missed.take(4).join(', ')}.',
      );
    }

    return TranslationEvaluation(
      estimatedScore: roundedScore,
      keywordCoverage: keywordCoverage,
      completenessRatio: completeness,
      matchedKeywords: matched,
      missedKeywords: missed,
      feedback: feedbackBuffer.toString(),
      isEstimated: true,
    );
  }

  /// Grades an entire 90-minute exam session out of 10.0 points.
  static ExamResult gradeExam({
    required ExamSession session,
    required ContentRepository repo,
    required int durationSeconds,
    required bool autoSubmitted,
  }) {
    // Part I: 20 MCQs * 0.125 = 2.5
    int correctMcq = 0;
    int wrongMcq = 0;
    int blankMcq = 0;
    final mcqReviews = <McqReviewItem>[];

    final chapterCorrect = <String, int>{};
    final chapterTotal = <String, int>{};

    for (int i = 0; i < session.mcqIds.length; i++) {
      final q = repo.findQuestionById(session.mcqIds[i]);
      if (q == null) continue;

      final order = session.mcqOptionOrders[i];
      final displayOptions = order.map((idx) => q.options[idx]).toList();
      final correctDisplayIndex = order.indexOf(q.correctIndex);
      final userDisplayIndex = session.mcqAnswers[i];

      chapterTotal[q.chapterId] = (chapterTotal[q.chapterId] ?? 0) + 1;

      if (userDisplayIndex == null) {
        blankMcq++;
      } else if (userDisplayIndex == correctDisplayIndex) {
        correctMcq++;
        chapterCorrect[q.chapterId] = (chapterCorrect[q.chapterId] ?? 0) + 1;
      } else {
        wrongMcq++;
      }

      mcqReviews.add(
        McqReviewItem(
          questionId: q.id,
          chapterId: q.chapterId,
          questionText: q.question,
          displayOptions: displayOptions,
          correctDisplayIndex: correctDisplayIndex,
          userDisplayIndex: userDisplayIndex,
          explanation: q.explanation,
          readingReference: q.readingReference,
        ),
      );
    }

    final part1Score = correctMcq * AppConstants.part1PointsPerQuestion;

    // Part II: 10 Terms * 0.25 = 2.5
    int correctTerms = 0;
    int wrongTerms = 0;
    final termReviews = <TermReviewItem>[];

    for (int i = 0; i < session.termIds.length; i++) {
      final v = repo.findVocabularyById(session.termIds[i]);
      if (v == null) continue;

      final userAns = session.termAnswers[i] ?? '';
      final isMatch =
          TextNormalizer.isTermMatch(userAns, v.allAcceptedVietnamese);

      chapterTotal[v.chapterId] = (chapterTotal[v.chapterId] ?? 0) + 1;
      if (isMatch) {
        correctTerms++;
        chapterCorrect[v.chapterId] = (chapterCorrect[v.chapterId] ?? 0) + 1;
      } else {
        wrongTerms++;
      }

      termReviews.add(
        TermReviewItem(
          termId: v.id,
          chapterId: v.chapterId,
          englishTerm: v.term,
          userAnswer: userAns,
          primaryVietnamese: v.vietnamese,
          acceptedTranslations: v.allAcceptedVietnamese,
          isCorrect: isMatch,
        ),
      );
    }

    final part2Score = correctTerms * AppConstants.part2PointsPerTerm;

    // Part III: 1 En -> Vi Paragraph (max 2.5)
    final enViPara = repo.findTranslationById(session.enViParagraphId);
    final enViEval = enViPara != null
        ? evaluateTranslationOffline(enViPara, session.enViAnswer)
        : const TranslationEvaluation(
            estimatedScore: 0,
            keywordCoverage: 0,
            completenessRatio: 0,
            matchedKeywords: [],
            missedKeywords: [],
            feedback: '',
          );

    // Part IV: 1 Vi -> En Paragraph (max 2.5)
    final viEnPara = repo.findTranslationById(session.viEnParagraphId);
    final viEnEval = viEnPara != null
        ? evaluateTranslationOffline(viEnPara, session.viEnAnswer)
        : const TranslationEvaluation(
            estimatedScore: 0,
            keywordCoverage: 0,
            completenessRatio: 0,
            matchedKeywords: [],
            missedKeywords: [],
            feedback: '',
          );

    final part3Score = enViEval.estimatedScore;
    final part4Score = viEnEval.estimatedScore;
    final totalScore =
        (part1Score + part2Score + part3Score + part4Score).clamp(0.0, 10.0);

    final chapterAccuracy = <String, double>{};
    for (final ch in AppConstants.chapters) {
      final tot = chapterTotal[ch.id] ?? 0;
      final cor = chapterCorrect[ch.id] ?? 0;
      chapterAccuracy[ch.id] = tot > 0 ? cor / tot : 0.0;
    }

    return ExamResult(
      id: session.id,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
      durationSeconds: durationSeconds,
      autoSubmitted: autoSubmitted,
      part1Score: part1Score,
      part2Score: part2Score,
      part3Score: part3Score,
      part4Score: part4Score,
      totalScore: totalScore,
      correctMcq: correctMcq,
      wrongMcq: wrongMcq,
      blankMcq: blankMcq,
      correctTerms: correctTerms,
      wrongTerms: wrongTerms,
      chapterAccuracy: chapterAccuracy,
      mcqReviews: mcqReviews,
      termReviews: termReviews,
      enViParagraphId: session.enViParagraphId,
      enViUserAnswer: session.enViAnswer,
      enViEval: enViEval,
      viEnParagraphId: session.viEnParagraphId,
      viEnUserAnswer: session.viEnAnswer,
      viEnEval: viEnEval,
    );
  }
}
