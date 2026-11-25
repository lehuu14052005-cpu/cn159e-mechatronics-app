import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/text_normalizer.dart';
import '../../models/vocabulary.dart';
import '../../providers/app_provider.dart';
import '../../widgets/chapter_badge.dart';

class TermTranslationScreen extends StatefulWidget {
  final String initialChapterId;
  final String initialMode; // en_vi, vi_en, random, mistakes, difficult

  const TermTranslationScreen({
    super.key,
    this.initialChapterId = 'all',
    this.initialMode = 'en_vi',
  });

  @override
  State<TermTranslationScreen> createState() => _TermTranslationScreenState();
}

class _TermTranslationScreenState extends State<TermTranslationScreen> {
  late String _chapterId;
  late String _mode;
  List<VocabularyItem> _terms = [];
  int _index = 0;
  bool _currentEnToVi = true;
  bool _checked = false;
  bool _isCorrect = false;
  final _answerCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chapterId = widget.initialChapterId;
    _mode = widget.initialMode;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTerms());
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  void _loadTerms() {
    final app = context.read<AppProvider>();
    final rng = Random();
    var list = List<VocabularyItem>.from(
      app.repository.vocabularyByChapter(_chapterId),
    );

    if (_mode == 'mistakes') {
      list = list.where((v) => app.wrongTermIds.contains(v.id)).toList();
    } else if (_mode == 'difficult') {
      list = list
          .where((v) => app.getProgressFor(v.id).isDifficult)
          .toList();
    }

    list.shuffle(rng);
    setState(() {
      _terms = list;
      _index = 0;
      _checked = false;
      _answerCtrl.clear();
      _currentEnToVi = _mode == 'vi_en'
          ? false
          : _mode == 'random'
              ? rng.nextBool()
              : true;
    });
  }

  Future<void> _checkAnswer() async {
    if (_terms.isEmpty || _checked) return;
    final item = _terms[_index];
    final userText = _answerCtrl.text;

    final match = _currentEnToVi
        ? TextNormalizer.isTermMatch(userText, item.allAcceptedVietnamese)
        : TextNormalizer.isTermMatch(userText, [item.term]);

    setState(() {
      _checked = true;
      _isCorrect = match;
    });

    await context
        .read<AppProvider>()
        .recordTermPractice(item.id, isCorrect: match);
  }

  void _next() {
    if (_terms.isEmpty) return;
    final rng = Random();
    setState(() {
      _index = (_index + 1) % _terms.length;
      _checked = false;
      _answerCtrl.clear();
      _currentEnToVi = _mode == 'vi_en'
          ? false
          : _mode == 'random'
              ? rng.nextBool()
              : true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = _terms.isNotEmpty ? _terms[_index] : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Luyện dịch thuật ngữ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _chapterId,
                  decoration: const InputDecoration(
                    labelText: 'Chương',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('Mixed Chapters')),
                    for (final ch in AppConstants.chapters)
                      DropdownMenuItem(value: ch.id, child: Text(ch.code)),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      _chapterId = v;
                      _loadTerms();
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _mode,
                  decoration: const InputDecoration(
                    labelText: 'Chế độ',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'en_vi', child: Text('EN → VI')),
                    DropdownMenuItem(value: 'vi_en', child: Text('VI → EN')),
                    DropdownMenuItem(value: 'random', child: Text('Random')),
                    DropdownMenuItem(value: 'mistakes', child: Text('Mistakes only')),
                    DropdownMenuItem(value: 'difficult', child: Text('Difficult only')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      _mode = v;
                      _loadTerms();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (item == null)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('Không có thuật ngữ nào trong chế độ này.'),
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ChapterBadge(chapterId: item.chapterId, compact: true),
                        Text(
                          '${_index + 1} / ${_terms.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentEnToVi
                          ? 'Dịch thuật ngữ sau sang Tiếng Việt:'
                          : 'Dịch thuật ngữ sau sang Tiếng Anh:',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentEnToVi ? item.term : item.vietnamese,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _answerCtrl,
                      enabled: !_checked,
                      decoration: InputDecoration(
                        hintText: _currentEnToVi
                            ? 'Nhập nghĩa tiếng Việt...'
                            : 'Nhập thuật ngữ tiếng Anh...',
                      ),
                      onSubmitted: (_) => _checkAnswer(),
                    ),
                    const SizedBox(height: 14),
                    if (!_checked)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _checkAnswer,
                          child: const Text('Kiểm tra đáp án'),
                        ),
                      )
                    else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (_isCorrect ? Colors.green : Colors.red)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isCorrect ? 'Chính xác!' : 'Chưa khớp đáp án mẫu',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: _isCorrect ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Đáp án chính: ${_currentEnToVi ? item.vietnamese : item.term}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (_currentEnToVi &&
                                item.acceptedTranslations.length > 1) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Biến thể chấp nhận: ${item.allAcceptedVietnamese.join(', ')}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _next,
                          child: const Text('Thuật ngữ tiếp theo'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
