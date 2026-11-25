class McqQuestion {
  final String id;
  final String chapterId;
  final String category;
  final String difficulty; // easy, medium, hard
  final String format; // en_vi, vi_en, en_en, vi_vi
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String readingReference;

  const McqQuestion({
    required this.id,
    required this.chapterId,
    required this.category,
    required this.difficulty,
    required this.format,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.readingReference,
  });

  factory McqQuestion.fromJson(Map<String, dynamic> json) {
    return McqQuestion(
      id: json['id'] as String,
      chapterId: json['chapterId'] as String,
      category: json['category'] as String? ?? 'General',
      difficulty: json['difficulty'] as String? ?? 'medium',
      format: json['format'] as String? ?? 'en_en',
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String? ?? '',
      readingReference: json['readingReference'] as String? ?? '',
    );
  }

  String get formatLabel {
    switch (format) {
      case 'en_vi':
        return 'EN → VI';
      case 'vi_en':
        return 'VI → EN';
      case 'en_en':
        return 'EN → EN';
      case 'vi_vi':
        return 'VI → VI';
      default:
        return format.toUpperCase();
    }
  }
}
