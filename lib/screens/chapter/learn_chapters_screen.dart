import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/app_provider.dart';
import '../../widgets/chapter_badge.dart';
import 'chapter_detail_screen.dart';

class LearnChaptersScreen extends StatelessWidget {
  const LearnChaptersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Học theo chương (Reading)'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: AppConstants.chapters.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ch = AppConstants.chapters[index];
          final color = Color(ch.colorHex);
          final progress = app.chapterVocabProgress(ch.id);
          final vocabCount = app.repository.vocabularyByChapter(ch.id).length;
          final quizCount = app.repository.questionsByChapter(ch.id).length;
          final transCount =
              app.repository.translationsByFilter(chapterId: ch.id).length;

          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChapterDetailScreen(chapter: ch),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            chapterIconData(ch.iconName),
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
                                ch.fullTitle,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                ch.vietnameseTitle,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      ch.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _MiniChip(label: '$vocabCount từ vựng', color: color),
                        _MiniChip(label: '$quizCount trắc nghiệm', color: color),
                        _MiniChip(label: '$transCount đoạn dịch', color: color),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              color: color,
                              backgroundColor: color.withValues(alpha: 0.14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
