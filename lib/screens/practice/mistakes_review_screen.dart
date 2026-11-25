import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../widgets/chapter_badge.dart';
import 'term_translation_screen.dart';

class MistakesReviewScreen extends StatelessWidget {
  const MistakesReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final wrongTerms = app.wrongTermIds
        .map((id) => app.repository.findVocabularyById(id))
        .where((v) => v != null)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Ôn tập lỗi sai (Mistakes Review)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.spellcheck_rounded, color: Colors.orange),
              title: Text('Thuật ngữ sai / chưa thuộc (${wrongTerms.length})'),
              subtitle: const Text('Ôn dịch lại các thuật ngữ hay nhầm'),
              trailing: FilledButton(
                onPressed: wrongTerms.isEmpty
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TermTranslationScreen(
                              initialMode: 'mistakes',
                            ),
                          ),
                        ),
                child: const Text('Ôn ngay'),
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (wrongTerms.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('Tuyệt vời! Bạn chưa có thuật ngữ nào cần ôn lại.'),
                ),
              ),
            )
          else ...[
            const Text(
              'Danh sách thuật ngữ cần ôn lại',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final v in wrongTerms)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    v!.term,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    v.vietnamese,
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  trailing: ChapterBadge(chapterId: v.chapterId, compact: true),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
