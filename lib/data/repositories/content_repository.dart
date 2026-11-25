import 'dart:convert';
import 'package:flutter/services.dart';

import '../../models/question.dart';
import '../../models/translation.dart';
import '../../models/vocabulary.dart';

class ContentRepository {
  List<VocabularyItem> _vocabulary = [];
  List<McqQuestion> _questions = [];
  List<TranslationParagraph> _translations = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<VocabularyItem> get vocabulary => _vocabulary;
  List<McqQuestion> get questions => _questions;
  List<TranslationParagraph> get translations => _translations;

  Future<void> loadAll() async {
    if (_loaded) return;

    final vocabJson = await rootBundle.loadString('assets/data/vocabulary.json');
    final questionsJson =
        await rootBundle.loadString('assets/data/questions.json');
    final translationsJson =
        await rootBundle.loadString('assets/data/translations.json');

    _vocabulary = (jsonDecode(vocabJson) as List)
        .map((e) => VocabularyItem.fromJson(e as Map<String, dynamic>))
        .toList();
    _questions = (jsonDecode(questionsJson) as List)
        .map((e) => McqQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
    _translations = (jsonDecode(translationsJson) as List)
        .map((e) => TranslationParagraph.fromJson(e as Map<String, dynamic>))
        .toList();

    _loaded = true;
  }

  List<VocabularyItem> vocabularyByChapter(String? chapterId) {
    if (chapterId == null || chapterId == 'all') return _vocabulary;
    return _vocabulary.where((v) => v.chapterId == chapterId).toList();
  }

  VocabularyItem? findVocabularyById(String id) {
    for (final v in _vocabulary) {
      if (v.id == id) return v;
    }
    return null;
  }

  List<McqQuestion> questionsByChapter(String? chapterId, {String? difficulty}) {
    return _questions.where((q) {
      final chOk = chapterId == null || chapterId == 'all' || q.chapterId == chapterId;
      final diffOk = difficulty == null || difficulty == 'all' || q.difficulty == difficulty;
      return chOk && diffOk;
    }).toList();
  }

  McqQuestion? findQuestionById(String id) {
    for (final q in _questions) {
      if (q.id == id) return q;
    }
    return null;
  }

  List<TranslationParagraph> translationsByFilter({
    String? chapterId,
    String? direction,
  }) {
    return _translations.where((t) {
      final chOk = chapterId == null || chapterId == 'all' || t.chapterId == chapterId;
      final dirOk = direction == null || direction == 'all' || t.direction == direction;
      return chOk && dirOk;
    }).toList();
  }

  TranslationParagraph? findTranslationById(String id) {
    for (final t in _translations) {
      if (t.id == id) return t;
    }
    return null;
  }
}
