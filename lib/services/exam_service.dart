import 'dart:math';

import '../core/constants/app_constants.dart';
import '../data/repositories/content_repository.dart';
import '../models/exam.dart';
import '../models/question.dart';
import '../models/vocabulary.dart';

class ExamService {
  ExamService._();

  static ExamSession createBalancedExam({
    required ContentRepository repo,
    required Map<String, int> chapterWeights,
  }) {
    final rng = Random();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final expectedEndMs =
        nowMs + AppConstants.examDurationSeconds * 1000;

    // 1. Select 20 unique MCQs balanced across 4 chapters
    final selectedMcqs = _pickBalancedMcqs(repo, chapterWeights, rng);
    selectedMcqs.shuffle(rng);

    final mcqIds = selectedMcqs.map((q) => q.id).toList();
    final mcqOptionOrders = selectedMcqs.map((q) {
      final indices = List<int>.generate(q.options.length, (i) => i);
      indices.shuffle(rng);
      return indices;
    }).toList();

    // 2. Select 10 unique Terms balanced across 4 chapters (3, 3, 2, 2 shuffled)
    final selectedTerms = _pickBalancedTerms(repo, rng);
    selectedTerms.shuffle(rng);
    final termIds = selectedTerms.map((v) => v.id).toList();

    // 3. Select 1 random En->Vi and 1 random Vi->En paragraph
    final enViList = repo.translationsByFilter(direction: 'en_vi');
    final viEnList = repo.translationsByFilter(direction: 'vi_en');

    final enViPara = enViList[rng.nextInt(enViList.length)];
    final viEnPara = viEnList[rng.nextInt(viEnList.length)];

    return ExamSession(
      id: 'exam_$nowMs',
      startedAtMs: nowMs,
      expectedEndAtMs: expectedEndMs,
      mcqIds: mcqIds,
      mcqOptionOrders: mcqOptionOrders,
      mcqAnswers: {},
      mcqFlagged: {},
      termIds: termIds,
      termAnswers: {},
      termFlagged: {},
      enViParagraphId: enViPara.id,
      enViAnswer: '',
      viEnParagraphId: viEnPara.id,
      viEnAnswer: '',
      isSubmitted: false,
    );
  }

  static List<McqQuestion> _pickBalancedMcqs(
    ContentRepository repo,
    Map<String, int> weights,
    Random rng,
  ) {
    final totalWeight = weights.values.fold<int>(0, (a, b) => a + b);
    final targetCounts = <String, int>{};

    if (totalWeight <= 0) {
      for (final ch in AppConstants.chapters) {
        targetCounts[ch.id] = 5;
      }
    } else {
      int assigned = 0;
      for (int i = 0; i < AppConstants.chapters.length; i++) {
        final ch = AppConstants.chapters[i];
        if (i == AppConstants.chapters.length - 1) {
          targetCounts[ch.id] = AppConstants.part1McqCount - assigned;
        } else {
          final count =
              ((weights[ch.id] ?? 5) * AppConstants.part1McqCount / totalWeight)
                  .round();
          targetCounts[ch.id] = count;
          assigned += count;
        }
      }
    }

    final picked = <McqQuestion>[];
    final usedIds = <String>{};

    for (final ch in AppConstants.chapters) {
      final pool = List<McqQuestion>.from(repo.questionsByChapter(ch.id))
        ..shuffle(rng);
      final need = targetCounts[ch.id] ?? 5;
      for (final q in pool) {
        if (picked.where((p) => p.chapterId == ch.id).length >= need) break;
        if (usedIds.add(q.id)) picked.add(q);
      }
    }

    // Top up if any chapter didn't have enough
    if (picked.length < AppConstants.part1McqCount) {
      final allPool = List<McqQuestion>.from(repo.questions)..shuffle(rng);
      for (final q in allPool) {
        if (picked.length >= AppConstants.part1McqCount) break;
        if (usedIds.add(q.id)) picked.add(q);
      }
    }

    return picked.take(AppConstants.part1McqCount).toList();
  }

  static List<VocabularyItem> _pickBalancedTerms(
    ContentRepository repo,
    Random rng,
  ) {
    // Distribute 10 terms as [3, 3, 2, 2] across shuffled chapters
    final counts = [3, 3, 2, 2]..shuffle(rng);
    final picked = <VocabularyItem>[];
    final usedIds = <String>{};

    for (int i = 0; i < AppConstants.chapters.length; i++) {
      final ch = AppConstants.chapters[i];
      final pool = repo
          .vocabularyByChapter(ch.id)
          .where((v) => !v.isSupplemental)
          .toList()
        ..shuffle(rng);
      int taken = 0;
      for (final v in pool) {
        if (taken >= counts[i]) break;
        if (usedIds.add(v.id)) {
          picked.add(v);
          taken++;
        }
      }
    }

    return picked.take(AppConstants.part2TermCount).toList();
  }
}
