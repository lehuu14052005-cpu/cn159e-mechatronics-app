import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/vocabulary.dart';
import '../../providers/app_provider.dart';
import '../../widgets/chapter_badge.dart';

class _VocabQuizItem {
  final VocabularyItem target;
  final bool enToVi;
  final List<VocabularyItem> options;
  final int correctIndex;

  const _VocabQuizItem({
    required this.target,
    required this.enToVi,
    required this.options,
    required this.correctIndex,
  });
}

class VocabularyQuizScreen extends StatefulWidget {
  final String initialChapterId;

  const VocabularyQuizScreen({super.key, this.initialChapterId = 'all'});

  @override
  State<VocabularyQuizScreen> createState() => _VocabularyQuizScreenState();
}

class _VocabularyQuizScreenState extends State<VocabularyQuizScreen> {
  late String _chapterId;
  String _direction = 'mixed'; // mixed, en_vi, vi_en

  List<_VocabQuizItem> _quiz = [];
  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _correctCount = 0;
  final List<VocabularyItem> _wrongItems = [];

  @override
  void initState() {
    super.initState();
    _chapterId = widget.initialChapterId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _startQuiz());
  }

  void _startQuiz({List<VocabularyItem>? customPool}) {
    final app = context.read<AppProvider>();
    final rng = Random();
    final allVocab = app.repository.vocabulary;

    final pool = customPool != null
        ? List<VocabularyItem>.from(customPool)
        : List<VocabularyItem>.from(
            app.repository.vocabularyByChapter(_chapterId),
          );

    if (pool.isEmpty) return;

    pool.shuffle(rng);

    final generated = <_VocabQuizItem>[];
    for (final target in pool) {
      final sameChapterDistractors = allVocab
          .where((v) => v.id != target.id && v.chapterId == target.chapterId)
          .toList()
        ..shuffle(rng);
      final otherDistractors = allVocab
          .where((v) => v.id != target.id && v.chapterId != target.chapterId)
          .toList()
        ..shuffle(rng);

      final distractors = <VocabularyItem>[];
      for (final d in [...sameChapterDistractors, ...otherDistractors]) {
        if (distractors.length >= 3) break;
        if (d.vietnamese != target.vietnamese && d.term != target.term) {
          distractors.add(d);
        }
      }

      final options = [target, ...distractors]..shuffle(rng);
      final correctIdx = options.indexWhere((v) => v.id == target.id);
      final enToVi = _direction == 'en_vi'
          ? true
          : _direction == 'vi_en'
              ? false
              : rng.nextBool();

      generated.add(
        _VocabQuizItem(
          target: target,
          enToVi: enToVi,
          options: options,
          correctIndex: correctIdx,
        ),
      );
    }

    setState(() {
      _quiz = generated;
      _currentIndex = 0;
      _selectedOption = null;
      _answered = false;
      _correctCount = 0;
      _wrongItems.clear();
    });
  }

  Future<void> _selectOption(int index) async {
    if (_answered) return;
    final item = _quiz[_currentIndex];
    final isCorrect = index == item.correctIndex;

    setState(() {
      _selectedOption = index;
      _answered = true;
      if (isCorrect) {
        _correctCount++;
      } else {
        _wrongItems.add(item.target);
      }
    });

    final app = context.read<AppProvider>();
    await app.markFlashcardResult(item.target.id, remembered: isCorrect);
    if (!isCorrect) {
      await app.recordTermPractice(item.target.id, isCorrect: false);
    }
  }

  void _next() {
    if (_currentIndex < _quiz.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      _showSummaryDialog();
    }
  }

  void _showSummaryDialog() {
    final pct = ((_correctCount / _quiz.length) * 100).round();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Hoàn thành trắc nghiệm từ vựng!'),
        content: Text(
          'Bạn trả lời đúng $_correctCount / ${_quiz.length} từ ($pct%).\n'
          'Các từ trả lời đúng đã được đánh dấu "Đã thuộc", từ sai được lưu vào mục cần ôn.',
        ),
        actions: [
          if (_wrongItems.isNotEmpty)
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _startQuiz(customPool: List<VocabularyItem>.from(_wrongItems));
              },
              child: Text('Ôn ${_wrongItems.length} từ sai'),
            ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startQuiz();
            },
            child: const Text('Xáo trộn làm lại'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = context.watch<AppProvider>();

    if (_quiz.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trắc nghiệm từ vựng')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final item = _quiz[_currentIndex];
    final target = item.target;

    return Scaffold(
      appBar: AppBar(
        title: Text('Từ ${_currentIndex + 1} / ${_quiz.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: Text(
                'Đúng: $_correctCount',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Chọn chương / chiều hỏi',
            icon: const Icon(Icons.tune_rounded),
            onSelected: (val) {
              if (val.startsWith('dir_')) {
                _direction = val.substring(4);
              } else {
                _chapterId = val;
              }
              _startQuiz();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                enabled: false,
                child: Text('Phạm vi chương',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              const PopupMenuItem(value: 'all', child: Text('Tất cả 4 chương')),
              for (final ch in AppConstants.chapters)
                PopupMenuItem(value: ch.id, child: Text(ch.fullTitle)),
              const PopupMenuDivider(),
              const PopupMenuItem(
                enabled: false,
                child: Text('Chiều hỏi',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              const PopupMenuItem(
                  value: 'dir_mixed', child: Text('Ngẫu nhiên 2 chiều')),
              const PopupMenuItem(
                  value: 'dir_en_vi', child: Text('English → Tiếng Việt')),
              const PopupMenuItem(
                  value: 'dir_vi_en', child: Text('Tiếng Việt → English')),
            ],
          ),
          IconButton(
            tooltip: 'Xáo trộn lại',
            icon: const Icon(Icons.shuffle_rounded),
            onPressed: () => _startQuiz(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _quiz.length,
            minHeight: 6,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ChapterBadge(chapterId: target.chapterId, compact: true),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          target.partOfSpeech,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    item.enToVi
                        ? 'Chọn nghĩa Tiếng Việt đúng cho:'
                        : 'Chọn thuật ngữ Tiếng Anh đúng cho:',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.enToVi ? target.term : target.vietnamese,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (item.enToVi &&
                      app.showPhonetic &&
                      target.phonetic.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      target.phonetic,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < item.options.length; i++) ...[
            _VocabOptionTile(
              label: String.fromCharCode(65 + i),
              text: item.enToVi
                  ? item.options[i].vietnamese
                  : item.options[i].term,
              isSelected: _selectedOption == i,
              isAnswered: _answered,
              isCorrectOption: i == item.correctIndex,
              onTap: () => _selectOption(i),
            ),
            const SizedBox(height: 10),
          ],
          if (_answered) ...[
            const SizedBox(height: 6),
            Card(
              color: theme.colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _selectedOption == item.correctIndex
                              ? Icons.check_circle_rounded
                              : Icons.info_rounded,
                          size: 18,
                          color: _selectedOption == item.correctIndex
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${target.term}  →  ${target.vietnamese}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (target.acceptedTranslations.length > 1) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Nghĩa tương đương: ${target.allAcceptedVietnamese.join(', ')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (target.exampleEn.isNotEmpty) ...[
                      const Divider(height: 16),
                      const Text(
                        'Ví dụ ngữ cảnh:',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        target.exampleEn,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (target.exampleVi.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          target.exampleVi,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _next,
                child: Text(
                  _currentIndex < _quiz.length - 1
                      ? 'Từ tiếp theo'
                      : 'Xem kết quả',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VocabOptionTile extends StatelessWidget {
  final String label;
  final String text;
  final bool isSelected;
  final bool isAnswered;
  final bool isCorrectOption;
  final VoidCallback onTap;

  const _VocabOptionTile({
    required this.label,
    required this.text,
    required this.isSelected,
    required this.isAnswered,
    required this.isCorrectOption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? borderColor;
    Color? bgColor;

    if (isAnswered) {
      if (isCorrectOption) {
        borderColor = Colors.green;
        bgColor = Colors.green.withValues(alpha: 0.1);
      } else if (isSelected) {
        borderColor = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.1);
      }
    } else if (isSelected) {
      borderColor = theme.colorScheme.primary;
      bgColor = theme.colorScheme.primary.withValues(alpha: 0.08);
    }

    return InkWell(
      onTap: isAnswered ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor ?? theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor ?? Colors.grey.withValues(alpha: 0.3),
            width: borderColor != null ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: borderColor?.withValues(alpha: 0.2) ??
                  theme.colorScheme.surfaceContainerHighest,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: borderColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
