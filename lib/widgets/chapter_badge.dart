import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class ChapterBadge extends StatelessWidget {
  final String chapterId;
  final bool compact;

  const ChapterBadge({
    super.key,
    required this.chapterId,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final ch = AppConstants.getChapter(chapterId);
    final color = Color(ch.colorHex);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        compact ? ch.code : ch.fullTitle,
        style: TextStyle(
          color: color,
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

IconData chapterIconData(String iconName) {
  switch (iconName) {
    case 'precision_manufacturing':
      return Icons.precision_manufacturing_rounded;
    case 'tune':
      return Icons.tune_rounded;
    case 'memory':
      return Icons.memory_rounded;
    case 'hub':
      return Icons.hub_rounded;
    default:
      return Icons.book_rounded;
  }
}
