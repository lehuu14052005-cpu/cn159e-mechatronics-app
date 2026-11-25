import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/exam.dart';
import '../../models/exam_result.dart';
import '../../models/translation.dart';
import '../../models/vocabulary.dart';

class StorageService {
  static const String _keyThemeMode = 'cn159e_theme_mode';
  static const String _keySeedColor = 'cn159e_seed_color';
  static const String _keyVocabProgress = 'cn159e_vocab_progress';
  static const String _keyWrongMcqIds = 'cn159e_wrong_mcq_ids';
  static const String _keyWrongTermIds = 'cn159e_wrong_term_ids';
  static const String _keyTotalMcqAnswered = 'cn159e_total_mcq_answered';
  static const String _keyTotalMcqCorrect = 'cn159e_total_mcq_correct';
  static const String _keyActiveExam = 'cn159e_active_exam';
  static const String _keyExamHistory = 'cn159e_exam_history';
  static const String _keyTranslationHistory = 'cn159e_translation_history';
  static const String _keyChapterWeights = 'cn159e_chapter_weights';
  static const String _keySoundEnabled = 'cn159e_sound_enabled';
  static const String _keyShowPhonetic = 'cn159e_show_phonetic';

  SharedPreferences? _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // Theme & Settings
  String getThemeMode() => _prefs?.getString(_keyThemeMode) ?? 'system';
  Future<void> setThemeMode(String mode) async =>
      await _prefs?.setString(_keyThemeMode, mode);

  int getSeedColor() => _prefs?.getInt(_keySeedColor) ?? 0xFF1565C0;
  Future<void> setSeedColor(int colorValue) async =>
      await _prefs?.setInt(_keySeedColor, colorValue);

  bool getSoundEnabled() => _prefs?.getBool(_keySoundEnabled) ?? true;
  Future<void> setSoundEnabled(bool v) async =>
      await _prefs?.setBool(_keySoundEnabled, v);

  bool getShowPhonetic() => _prefs?.getBool(_keyShowPhonetic) ?? true;
  Future<void> setShowPhonetic(bool v) async =>
      await _prefs?.setBool(_keyShowPhonetic, v);

  Map<String, int> getChapterWeights() {
    final raw = _prefs?.getString(_keyChapterWeights);
    if (raw == null) {
      return {'ch4': 5, 'ch5_1': 5, 'ch5_2': 5, 'ch6': 5};
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as int));
  }

  Future<void> setChapterWeights(Map<String, int> weights) async =>
      await _prefs?.setString(_keyChapterWeights, jsonEncode(weights));

  // Vocabulary Progress
  Map<String, VocabularyProgress> getVocabProgress() {
    final raw = _prefs?.getString(_keyVocabProgress);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (k, v) => MapEntry(k, VocabularyProgress.fromJson(v as Map<String, dynamic>)),
    );
  }

  Future<void> saveVocabProgress(Map<String, VocabularyProgress> map) async {
    final encoded = map.map((k, v) => MapEntry(k, v.toJson()));
    await _prefs?.setString(_keyVocabProgress, jsonEncode(encoded));
  }

  // Mistakes & Practice stats
  Set<String> getWrongMcqIds() =>
      Set<String>.from(_prefs?.getStringList(_keyWrongMcqIds) ?? []);
  Future<void> saveWrongMcqIds(Set<String> ids) async =>
      await _prefs?.setStringList(_keyWrongMcqIds, ids.toList());

  Set<String> getWrongTermIds() =>
      Set<String>.from(_prefs?.getStringList(_keyWrongTermIds) ?? []);
  Future<void> saveWrongTermIds(Set<String> ids) async =>
      await _prefs?.setStringList(_keyWrongTermIds, ids.toList());

  int getTotalMcqAnswered() => _prefs?.getInt(_keyTotalMcqAnswered) ?? 0;
  Future<void> setTotalMcqAnswered(int count) async =>
      await _prefs?.setInt(_keyTotalMcqAnswered, count);

  int getTotalMcqCorrect() => _prefs?.getInt(_keyTotalMcqCorrect) ?? 0;
  Future<void> setTotalMcqCorrect(int count) async =>
      await _prefs?.setInt(_keyTotalMcqCorrect, count);

  // Active Exam Session (survives app close / background)
  ExamSession? getActiveExam() {
    final raw = _prefs?.getString(_keyActiveExam);
    if (raw == null) return null;
    return ExamSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveActiveExam(ExamSession? session) async {
    if (session == null) {
      await _prefs?.remove(_keyActiveExam);
      return;
    }
    await _prefs?.setString(_keyActiveExam, jsonEncode(session.toJson()));
  }

  // Exam History
  List<ExamResult> getExamHistory() {
    final raw = _prefs?.getString(_keyExamHistory);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => ExamResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveExamHistory(List<ExamResult> history) async {
    await _prefs?.setString(
      _keyExamHistory,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  // Translation Practice History
  List<TranslationHistoryItem> getTranslationHistory() {
    final raw = _prefs?.getString(_keyTranslationHistory);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => TranslationHistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTranslationHistory(List<TranslationHistoryItem> history) async {
    await _prefs?.setString(
      _keyTranslationHistory,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  // Export & Import all user data
  Map<String, dynamic> exportAllData() {
    return {
      'version': 1,
      'exportedAtMs': DateTime.now().millisecondsSinceEpoch,
      'themeMode': getThemeMode(),
      'seedColor': getSeedColor(),
      'soundEnabled': getSoundEnabled(),
      'showPhonetic': getShowPhonetic(),
      'chapterWeights': getChapterWeights(),
      'vocabProgress': getVocabProgress().map((k, v) => MapEntry(k, v.toJson())),
      'wrongMcqIds': getWrongMcqIds().toList(),
      'wrongTermIds': getWrongTermIds().toList(),
      'totalMcqAnswered': getTotalMcqAnswered(),
      'totalMcqCorrect': getTotalMcqCorrect(),
      'examHistory': getExamHistory().map((e) => e.toJson()).toList(),
      'translationHistory':
          getTranslationHistory().map((e) => e.toJson()).toList(),
    };
  }

  Future<void> importAllData(Map<String, dynamic> data) async {
    if (data['themeMode'] is String) {
      await setThemeMode(data['themeMode'] as String);
    }
    if (data['seedColor'] is int) {
      await setSeedColor(data['seedColor'] as int);
    }
    if (data['soundEnabled'] is bool) {
      await setSoundEnabled(data['soundEnabled'] as bool);
    }
    if (data['showPhonetic'] is bool) {
      await setShowPhonetic(data['showPhonetic'] as bool);
    }
    if (data['chapterWeights'] is Map) {
      final w = (data['chapterWeights'] as Map)
          .map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
      await setChapterWeights(w);
    }
    if (data['vocabProgress'] is Map) {
      final vp = (data['vocabProgress'] as Map).map(
        (k, v) => MapEntry(
          k.toString(),
          VocabularyProgress.fromJson(v as Map<String, dynamic>),
        ),
      );
      await saveVocabProgress(vp);
    }
    if (data['wrongMcqIds'] is List) {
      await saveWrongMcqIds(
          Set<String>.from(data['wrongMcqIds'] as List));
    }
    if (data['wrongTermIds'] is List) {
      await saveWrongTermIds(
          Set<String>.from(data['wrongTermIds'] as List));
    }
    if (data['totalMcqAnswered'] is int) {
      await setTotalMcqAnswered(data['totalMcqAnswered'] as int);
    }
    if (data['totalMcqCorrect'] is int) {
      await setTotalMcqCorrect(data['totalMcqCorrect'] as int);
    }
    if (data['examHistory'] is List) {
      final eh = (data['examHistory'] as List)
          .map((e) => ExamResult.fromJson(e as Map<String, dynamic>))
          .toList();
      await saveExamHistory(eh);
    }
    if (data['translationHistory'] is List) {
      final th = (data['translationHistory'] as List)
          .map((e) =>
              TranslationHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
      await saveTranslationHistory(th);
    }
  }

  Future<void> resetAllData() async {
    await _prefs?.clear();
  }
}
