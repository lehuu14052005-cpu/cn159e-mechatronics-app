import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/app_provider.dart';
import '../../widgets/stat_card.dart';
import '../practice/mistakes_review_screen.dart';
import '../practice/term_translation_screen.dart';
import '../translation/paragraph_translation_screen.dart';
import '../vocabulary/vocabulary_quiz_screen.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int> onSwitchTab;

  const DashboardScreen({super.key, required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final theme = Theme.of(context);

    final learned = app.learnedVocabCount;
    final totalVocab = app.totalVocabCount;
    final vocabPct = totalVocab > 0 ? learned / totalVocab : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CN159E – Mechatronics'),
            Text(
              'Anh văn chuyên môn Cơ điện tử',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Hero progress card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.82),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tiến độ học tập',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$learned / $totalVocab thuật ngữ đã thuộc',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        '${(vocabPct * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: vocabPct,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Quick Actions Grid
          Text(
            'Chức năng học tập',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: [
              _QuickActionCard(
                title: 'Vocab Quiz',
                subtitle: 'Trắc nghiệm từ vựng',
                icon: Icons.fact_check_rounded,
                color: const Color(0xFF00695C),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VocabularyQuizScreen(),
                  ),
                ),
              ),
              _QuickActionCard(
                title: 'Term Translation',
                subtitle: 'Dịch thuật ngữ Anh ↔ Việt',
                icon: Icons.spellcheck_rounded,
                color: const Color(0xFF1565C0),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TermTranslationScreen(),
                  ),
                ),
              ),
              _QuickActionCard(
                title: 'Translation',
                subtitle: '${app.repository.translations.length} đoạn luyện dịch',
                icon: Icons.translate_rounded,
                color: const Color(0xFF0277BD),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ParagraphTranslationScreen(),
                  ),
                ),
              ),
              _QuickActionCard(
                title: 'Mistakes Review',
                subtitle: '${app.wrongTermIds.length} thuật ngữ cần ôn',
                icon: Icons.error_outline_rounded,
                color: const Color(0xFFEF6C00),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MistakesReviewScreen(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Text(
            'Thống kê học tập',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Đã thuộc',
                  value: '$learned',
                  icon: Icons.check_circle_outline_rounded,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Từ cần ôn',
                  value: '${app.needReviewVocabCount}',
                  icon: Icons.bookmark_border_rounded,
                  color: const Color(0xFFEF6C00),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Bài dịch đã lưu',
                  value: '${app.translationHistory.length}',
                  icon: Icons.edit_note_rounded,
                  color: const Color(0xFF1565C0),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tiến độ từ vựng theo chương',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final ch in AppConstants.chapters) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ch.fullTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${(app.chapterVocabProgress(ch.id) * 100).round()}%',
                          style: TextStyle(
                            color: Color(ch.colorHex),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: app.chapterVocabProgress(ch.id),
                        minHeight: 7,
                        color: Color(ch.colorHex),
                        backgroundColor:
                            Color(ch.colorHex).withValues(alpha: 0.14),
                      ),
                    ),
                    const SizedBox(height: 10),
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

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
