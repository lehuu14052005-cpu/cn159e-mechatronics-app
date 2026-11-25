import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chapter.dart';
import '../../providers/app_provider.dart';
import '../../widgets/chapter_badge.dart';
import '../practice/term_translation_screen.dart';
import '../translation/paragraph_translation_screen.dart';
import '../vocabulary/vocabulary_quiz_screen.dart';

class ChapterDetailScreen extends StatelessWidget {
  final ChapterInfo chapter;

  const ChapterDetailScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final color = Color(chapter.colorHex);
    final progress = app.chapterVocabProgress(chapter.id);

    return Scaffold(
      appBar: AppBar(title: Text(chapter.fullTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: color.withValues(alpha: 0.14),
                        child: Icon(
                          chapterIconData(chapter.iconName),
                          color: color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chapter.vietnameseTitle,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Phạm vi Reading chính thức',
                              style: TextStyle(color: color, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(chapter.description),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Đã thuộc ${(progress * 100).round()}% từ vựng chương này',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ActionTile(
            icon: Icons.fact_check_rounded,
            color: color,
            title: 'Trắc nghiệm từ vựng',
            subtitle:
                '${app.repository.vocabularyByChapter(chapter.id).length} từ vựng – chọn nghĩa đúng A/B/C/D',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    VocabularyQuizScreen(initialChapterId: chapter.id),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.spellcheck_rounded,
            color: color,
            title: 'Luyện dịch thuật ngữ',
            subtitle: 'Gõ nghĩa tiếng Việt / tiếng Anh cho thuật ngữ chương này',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    TermTranslationScreen(initialChapterId: chapter.id),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.translate_rounded,
            color: color,
            title: 'Luyện dịch đoạn văn',
            subtitle:
                '${app.repository.translationsByFilter(chapterId: chapter.id).length} đoạn Anh-Việt & Việt-Anh',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ParagraphTranslationScreen(initialChapterId: chapter.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
