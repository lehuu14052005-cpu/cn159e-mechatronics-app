class ChapterInfo {
  final String id;
  final String code;
  final String title;
  final String vietnameseTitle;
  final String description;
  final String iconName;
  final int colorHex;

  const ChapterInfo({
    required this.id,
    required this.code,
    required this.title,
    required this.vietnameseTitle,
    required this.description,
    required this.iconName,
    required this.colorHex,
  });

  String get fullTitle => '$code – $title';
}
