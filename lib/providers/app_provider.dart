import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../data/repositories/content_repository.dart';
import '../models/exam_result.dart';
import '../models/translation.dart';
import '../models/vocabulary.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final ContentRepository repository;
  final StorageService storage;

  AppProvider({required this.repository, required this.storage});

  bool _initialized = false;
  bool get initialized => _initialized;

  String _themeModeStr = 'system';
  int _seedColorValue = 0xFF1565C0;
  bool _soundEnabled = true;
  bool _showPhonetic = true;
  Map<String, int> _chapterWeights = {'ch4': 5, 'ch5_1': 5, 'ch5_2': 5, 'ch6': 5};

  Map<String, VocabularyProgress> _vocabProgress = {};
  Set<String> _wrongMcqIds = {};
  Set<String> _wrongTermIds = {};
  int _totalMcqAnswered = 0;
  int _totalMcqCorrect = 0;
  List<ExamResult> _examHistory = [];
  List<TranslationHistoryItem> _translationHistory = [];

  ThemeMode get themeMode {
    switch (_themeModeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String get themeModeStr => _themeModeStr;
  Color get seedColor => Color(_seedColorValue);
  int get seedColorValue => _seedColorValue;
  bool get soundEnabled => _soundEnabled;
  bool get showPhonetic => _showPhonetic;
  Map<String, int> get chapterWeights => Map.unmodifiable(_chapterWeights);

  Map<String, VocabularyProgress> get vocabProgress => _vocabProgress;
  Set<String> get wrongMcqIds => _wrongMcqIds;
  Set<String> get wrongTermIds => _wrongTermIds;
  int get totalMcqAnswered => _totalMcqAnswered;
  int get totalMcqCorrect => _totalMcqCorrect;
  List<ExamResult> get examHistory => _examHistory;
  List<TranslationHistoryItem> get translationHistory => _translationHistory;

  Future<void> initialize() async {
    await repository.loadAll();
    _reloadFromStorage();
    _initialized = true;
    notifyListeners();
  }

  void _reloadFromStorage() {
    _themeModeStr = storage.getThemeMode();
    _seedColorValue = storage.getSeedColor();
    _soundEnabled = storage.getSoundEnabled();
    _showPhonetic = storage.getShowPhonetic();
    _chapterWeights = storage.getChapterWeights();
    _vocabProgress = storage.getVocabProgress();
    _wrongMcqIds = storage.getWrongMcqIds();
    _wrongTermIds = storage.getWrongTermIds();
    _totalMcqAnswered = storage.getTotalMcqAnswered();
    _totalMcqCorrect = storage.getTotalMcqCorrect();
    _examHistory = storage.getExamHistory()
      ..sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
    _translationHistory = storage.getTranslationHistory()
      ..sort((a, b) => b.timestampMs.compareTo(a.timestampMs));
  }

  void reloadAfterImport() {
    _reloadFromStorage();
    notifyListeners();
  }

  // Settings
  Future<void> setThemeMode(String mode) async {
    _themeModeStr = mode;
    await storage.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> setSeedColor(int colorValue) async {
    _seedColorValue = colorValue;
    await storage.setSeedColor(colorValue);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await storage.setSoundEnabled(enabled);
    notifyListeners();
  }

  Future<void> setShowPhonetic(bool show) async {
    _showPhonetic = show;
    await storage.setShowPhonetic(show);
    notifyListeners();
  }

  Future<void> setChapterWeights(Map<String, int> weights) async {
    _chapterWeights = Map<String, int>.from(weights);
    await storage.setChapterWeights(_chapterWeights);
    notifyListeners();
  }

  // Vocabulary progress
  VocabularyProgress getProgressFor(String vocabId) {
    return _vocabProgress[vocabId] ?? const VocabularyProgress();
  }

  Future<void> toggleLearned(String vocabId) async {
    final current = getProgressFor(vocabId);
    _vocabProgress[vocabId] = current.copyWith(
      isLearned: !current.isLearned,
      needsReview: current.isLearned ? current.needsReview : false,
      reviewCount: current.reviewCount + 1,
    );
    await storage.saveVocabProgress(_vocabProgress);
    notifyListeners();
  }

  Future<void> toggleDifficult(String vocabId) async {
    final current = getProgressFor(vocabId);
    _vocabProgress[vocabId] = current.copyWith(
      isDifficult: !current.isDifficult,
    );
    await storage.saveVocabProgress(_vocabProgress);
    notifyListeners();
  }

  Future<void> markFlashcardResult(String vocabId, {required bool remembered}) async {
    final current = getProgressFor(vocabId);
    _vocabProgress[vocabId] = current.copyWith(
      isLearned: remembered,
      needsReview: !remembered,
      reviewCount: current.reviewCount + 1,
    );
    await storage.saveVocabProgress(_vocabProgress);
    notifyListeners();
  }

  // Practice Quiz stats
  Future<void> recordMcqPractice(String questionId, {required bool isCorrect}) async {
    _totalMcqAnswered++;
    if (isCorrect) {
      _totalMcqCorrect++;
      _wrongMcqIds.remove(questionId);
    } else {
      _wrongMcqIds.add(questionId);
    }
    await storage.setTotalMcqAnswered(_totalMcqAnswered);
    await storage.setTotalMcqCorrect(_totalMcqCorrect);
    await storage.saveWrongMcqIds(_wrongMcqIds);
    notifyListeners();
  }

  // Term translation stats
  Future<void> recordTermPractice(String termId, {required bool isCorrect}) async {
    if (isCorrect) {
      _wrongTermIds.remove(termId);
    } else {
      _wrongTermIds.add(termId);
    }
    await storage.saveWrongTermIds(_wrongTermIds);
    notifyListeners();
  }

  // Exam history
  Future<void> addExamResult(ExamResult result) async {
    _examHistory.insert(0, result);
    // Also record wrong MCQs and terms from the exam into mistakes bank
    for (final m in result.mcqReviews) {
      if (!m.isCorrect) {
        _wrongMcqIds.add(m.questionId);
      }
    }
    for (final t in result.termReviews) {
      if (!t.isCorrect) {
        _wrongTermIds.add(t.termId);
      }
    }
    await storage.saveExamHistory(_examHistory);
    await storage.saveWrongMcqIds(_wrongMcqIds);
    await storage.saveWrongTermIds(_wrongTermIds);
    notifyListeners();
  }

  // Translation history
  Future<void> addTranslationHistory(TranslationHistoryItem item) async {
    _translationHistory.insert(0, item);
    await storage.saveTranslationHistory(_translationHistory);
    notifyListeners();
  }

  Future<void> resetAllData() async {
    await storage.resetAllData();
    _reloadFromStorage();
    notifyListeners();
  }

  // Computed Statistics
  int get learnedVocabCount =>
      _vocabProgress.values.where((p) => p.isLearned).length;

  int get needReviewVocabCount =>
      _vocabProgress.values.where((p) => p.needsReview || p.isDifficult).length;

  int get totalVocabCount => repository.vocabulary.length;

  double chapterVocabProgress(String chapterId) {
    final items = repository.vocabularyByChapter(chapterId);
    if (items.isEmpty) return 0.0;
    final learned = items.where((v) => getProgressFor(v.id).isLearned).length;
    return learned / items.length;
  }

  double get highestExamScore {
    if (_examHistory.isEmpty) return 0.0;
    return _examHistory.map((e) => e.totalScore).reduce((a, b) => a > b ? a : b);
  }

  double get averageExamScore {
    if (_examHistory.isEmpty) return 0.0;
    final sum = _examHistory.fold<double>(0.0, (a, b) => a + b.totalScore);
    return sum / _examHistory.length;
  }

  double? get latestExamScore =>
      _examHistory.isEmpty ? null : _examHistory.first.totalScore;

  Map<String, double> get averageChapterAccuracy {
    final totals = <String, double>{};
    final counts = <String, int>{};
    for (final ch in AppConstants.chapters) {
      totals[ch.id] = 0.0;
      counts[ch.id] = 0;
    }
    for (final res in _examHistory) {
      res.chapterAccuracy.forEach((chId, acc) {
        totals[chId] = (totals[chId] ?? 0.0) + acc;
        counts[chId] = (counts[chId] ?? 0) + 1;
      });
    }
    return {
      for (final ch in AppConstants.chapters)
        ch.id: (counts[ch.id] ?? 0) > 0
            ? totals[ch.id]! / counts[ch.id]!
            : 0.0,
    };
  }
}
