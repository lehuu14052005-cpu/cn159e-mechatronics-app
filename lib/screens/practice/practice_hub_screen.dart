import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../translation/paragraph_translation_screen.dart';
import '../vocabulary/vocabulary_quiz_screen.dart';
import 'mistakes_review_screen.dart';
import 'term_translation_screen.dart';

class PracticeHubScreen extends StatelessWidget {
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final mistakesCount = app.wrongTermIds.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Luyện tập chuyên sâu')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PracticeModeCard(
            icon: Icons.fact_check_rounded,
            color: const Color(0xFF00695C),
            title: 'Vocabulary Quiz (Trắc nghiệm từ vựng)',
            subtitle:
                'Học từ vựng chuyên ngành theo kiểu trắc nghiệm 4 lựa chọn A/B/C/D.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VocabularyQuizScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _PracticeModeCard(
            icon: Icons.spellcheck_rounded,
            color: const Color(0xFF00838F),
            title: 'Term Translation (Dịch thuật ngữ)',
            subtitle:
                'Luyện gõ nghĩa Anh → Việt, Việt → Anh, từ khó hoặc thuật ngữ hay sai.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermTranslationScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _PracticeModeCard(
            icon: Icons.translate_rounded,
            color: const Color(0xFF283593),
            title: 'Paragraph Translation (Dịch đoạn văn)',
            subtitle:
                'Luyện dịch đoạn văn Reading Anh ↔ Việt có chấm rubric, từ khóa và gợi ý ngữ pháp.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ParagraphTranslationScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _PracticeModeCard(
            icon: Icons.error_outline_rounded,
            color: const Color(0xFFEF6C00),
            title: 'Mistakes Review (Ôn lỗi sai)',
            subtitle: 'Hiện có $mistakesCount thuật ngữ cần ôn lại.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MistakesReviewScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeModeCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PracticeModeCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
