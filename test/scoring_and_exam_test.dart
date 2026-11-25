import 'package:cn159e_app/core/constants/app_constants.dart';
import 'package:cn159e_app/core/utils/text_normalizer.dart';
import 'package:cn159e_app/data/repositories/content_repository.dart';
import 'package:cn159e_app/services/exam_service.dart';
import 'package:cn159e_app/services/scoring_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('TextNormalizer handles case, punctuation, equivalents, and near matches', () {
    expect(
      TextNormalizer.isTermMatch('  Cơ Cấu Chấp Hành!! ', ['cơ cấu chấp hành']),
      isTrue,
    );
    expect(
      TextNormalizer.isTermMatch('bo truyen dong', ['cơ cấu chấp hành', 'bộ truyền động']),
      isTrue,
    );
    // Near matches (parentheses, filler words, minor typo)
    expect(
      TextNormalizer.isTermMatch('tầng cảm nhận', ['tầng cảm nhận (tầng thu nhận)']),
      isTrue,
    );
    expect(
      TextNormalizer.isTermMatch('các cơ cấu chấp hanh', ['cơ cấu chấp hành']),
      isTrue,
    );
    expect(
      TextNormalizer.isTermMatch('hệ thống chống bó cứng phanh', ['hệ thống chống bó cứng phanh (ABS)']),
      isTrue,
    );
    expect(
      TextNormalizer.isTermMatch('cam bien nhiet do', ['cơ cấu chấp hành']),
      isFalse,
    );
  });

  test('ExamService generates balanced 90-minute exam and ScoringService totals 10', () async {
    final repo = ContentRepository();
    await repo.loadAll();

    expect(repo.vocabulary.length, greaterThanOrEqualTo(150));
    expect(repo.questions.length, greaterThanOrEqualTo(100));
    expect(repo.translations.where((t) => t.direction == 'en_vi').length, 40);
    expect(repo.translations.where((t) => t.direction == 'vi_en').length, 40);

    final session = ExamService.createBalancedExam(
      repo: repo,
      chapterWeights: const {'ch4': 5, 'ch5_1': 5, 'ch5_2': 5, 'ch6': 5},
    );

    expect(session.mcqIds.length, AppConstants.part1McqCount);
    expect(session.mcqIds.toSet().length, AppConstants.part1McqCount);
    expect(session.termIds.length, AppConstants.part2TermCount);
    expect(session.termIds.toSet().length, AppConstants.part2TermCount);

    // Verify all 4 chapters are represented in MCQs
    final chaptersUsed = session.mcqIds
        .map((id) => repo.findQuestionById(id)!.chapterId)
        .toSet();
    expect(chaptersUsed.length, 4);

    // Perfect answers test
    final perfectMcqAnswers = <int, int>{};
    for (int i = 0; i < session.mcqIds.length; i++) {
      final q = repo.findQuestionById(session.mcqIds[i])!;
      perfectMcqAnswers[i] = session.mcqOptionOrders[i].indexOf(q.correctIndex);
    }

    final perfectTermAnswers = <int, String>{};
    for (int i = 0; i < session.termIds.length; i++) {
      final v = repo.findVocabularyById(session.termIds[i])!;
      perfectTermAnswers[i] = v.vietnamese;
    }

    final enViPara = repo.findTranslationById(session.enViParagraphId)!;
    final viEnPara = repo.findTranslationById(session.viEnParagraphId)!;

    final filled = session.copyWith(
      mcqAnswers: perfectMcqAnswers,
      termAnswers: perfectTermAnswers,
      enViAnswer: enViPara.sampleTranslation,
      viEnAnswer: viEnPara.sampleTranslation,
    );

    final result = ScoringService.gradeExam(
      session: filled,
      repo: repo,
      durationSeconds: 1800,
      autoSubmitted: false,
    );

    expect(result.part1Score, 2.5);
    expect(result.part2Score, 2.5);
    expect(result.part3Score, 2.5);
    expect(result.part4Score, 2.5);
    expect(result.totalScore, 10.0);
  });
}
