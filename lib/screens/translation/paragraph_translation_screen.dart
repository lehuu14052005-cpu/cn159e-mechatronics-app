import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/translation.dart';
import '../../providers/app_provider.dart';
import '../../services/scoring_service.dart';
import '../../widgets/chapter_badge.dart';

class ParagraphTranslationScreen extends StatefulWidget {
  final String initialChapterId;

  const ParagraphTranslationScreen({
    super.key,
    this.initialChapterId = 'all',
  });

  @override
  State<ParagraphTranslationScreen> createState() =>
      _ParagraphTranslationScreenState();
}

class _ParagraphTranslationScreenState
    extends State<ParagraphTranslationScreen> {
  late String _chapterId;
  String _direction = 'en_vi';
  List<TranslationParagraph> _items = [];
  int _index = 0;
  final _ctrl = TextEditingController();
  TranslationEvaluation? _eval;

  @override
  void initState() {
    super.initState();
    _chapterId = widget.initialChapterId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadItems());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _loadItems() {
    final app = context.read<AppProvider>();
    final list = List<TranslationParagraph>.from(
      app.repository.translationsByFilter(
        chapterId: _chapterId,
        direction: _direction,
      ),
    )..shuffle(Random());

    setState(() {
      _items = list;
      _index = 0;
      _ctrl.clear();
      _eval = null;
    });
  }

  Future<void> _submitTranslation() async {
    if (_items.isEmpty) return;
    final item = _items[_index];
    final result =
        ScoringService.evaluateTranslationOffline(item, _ctrl.text);

    setState(() => _eval = result);

    await context.read<AppProvider>().addTranslationHistory(
          TranslationHistoryItem(
            id: 'th_${DateTime.now().millisecondsSinceEpoch}',
            paragraphId: item.id,
            chapterId: item.chapterId,
            direction: item.direction,
            title: item.title,
            userAnswer: _ctrl.text.trim(),
            estimatedScore: result.estimatedScore,
            timestampMs: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  void _nextItem() {
    if (_items.isEmpty) return;
    setState(() {
      _index = (_index + 1) % _items.length;
      _ctrl.clear();
      _eval = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final item = _items.isNotEmpty ? _items[_index] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Luyện dịch đoạn văn'),
        actions: [
          IconButton(
            tooltip: 'Lịch sử luyện dịch',
            icon: const Icon(Icons.history_rounded),
            onPressed: () => _showHistorySheet(context, app.translationHistory),
          ),
        ],
      ),
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
                      _loadItems();
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _direction,
                  decoration: const InputDecoration(
                    labelText: 'Chiều dịch',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'en_vi', child: Text('Anh → Việt')),
                    DropdownMenuItem(value: 'vi_en', child: Text('Việt → Anh')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      _direction = v;
                      _loadItems();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (item == null)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Không có đoạn văn phù hợp.')),
              ),
            )
          else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ChapterBadge(chapterId: item.chapterId, compact: true),
                        Text(
                          '${_index + 1} / ${_items.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      item.sourceText,
                      style: const TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              maxLines: 6,
              minLines: 4,
              decoration: InputDecoration(
                labelText: _direction == 'en_vi'
                    ? 'Nhập bản dịch tiếng Việt'
                    : 'Nhập bản dịch tiếng Anh',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _nextItem,
                    child: const Text('Đoạn khác'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _submitTranslation,
                    icon: const Icon(Icons.fact_check_rounded),
                    label: const Text('Chấm & Xem đáp án'),
                  ),
                ),
              ],
            ),
            if (_eval != null) ...[
              const SizedBox(height: 16),
              _TranslationFeedbackCard(paragraph: item, eval: _eval!),
            ],
          ],
        ],
      ),
    );
  }

  void _showHistorySheet(
    BuildContext context,
    List<TranslationHistoryItem> history,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Lịch sử luyện dịch',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('Chưa có bài dịch nào được lưu.')),
            )
          else
            for (final h in history.take(20))
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    h.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  ),
                  subtitle: Text(
                    h.userAnswer.isEmpty ? '(Bỏ trống)' : h.userAnswer,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    '~${h.estimatedScore.toStringAsFixed(2)}/2.5',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _TranslationFeedbackCard extends StatelessWidget {
  final TranslationParagraph paragraph;
  final TranslationEvaluation eval;

  const _TranslationFeedbackCard({
    required this.paragraph,
    required this.eval,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Đánh giá & Bản dịch mẫu',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                Chip(
                  label: Text(
                    'Ước lượng: ${eval.estimatedScore.toStringAsFixed(2)} / 2.5',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              eval.feedback,
              style: TextStyle(
                fontSize: 12.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 20),
            const Text(
              'Bản dịch mẫu tham khảo:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              paragraph.sampleTranslation,
              style: const TextStyle(fontSize: 13.5, height: 1.45),
            ),
            const SizedBox(height: 12),
            const Text(
              'Thuật ngữ chuyên ngành quan trọng:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: paragraph.keyTerms
                  .map(
                    (kt) => Chip(
                      label: Text('${kt.en}: ${kt.vi}',
                          style: const TextStyle(fontSize: 11.5)),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
            if (paragraph.grammarOrTranslationHints.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Gợi ý: ${paragraph.grammarOrTranslationHints}',
                style: const TextStyle(fontSize: 12.5),
              ),
            ],
            if (paragraph.importantNotes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Nguồn: ${paragraph.importantNotes}',
                style: TextStyle(
                  fontSize: 11.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
