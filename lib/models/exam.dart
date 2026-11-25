class ExamSession {
  final String id;
  final int startedAtMs;
  final int expectedEndAtMs;
  final List<String> mcqIds;

  /// For each MCQ, stores shuffled option indices mapping display index -> original index
  final List<List<int>> mcqOptionOrders;

  /// Map of question index ("0".."19") -> selected display option index
  final Map<int, int> mcqAnswers;
  final Set<int> mcqFlagged;

  final List<String> termIds;
  final Map<int, String> termAnswers;
  final Set<int> termFlagged;

  final String enViParagraphId;
  final String enViAnswer;

  final String viEnParagraphId;
  final String viEnAnswer;

  final bool isSubmitted;

  const ExamSession({
    required this.id,
    required this.startedAtMs,
    required this.expectedEndAtMs,
    required this.mcqIds,
    required this.mcqOptionOrders,
    required this.mcqAnswers,
    required this.mcqFlagged,
    required this.termIds,
    required this.termAnswers,
    required this.termFlagged,
    required this.enViParagraphId,
    required this.enViAnswer,
    required this.viEnParagraphId,
    required this.viEnAnswer,
    this.isSubmitted = false,
  });

  int remainingSecondsAt(int nowMs) {
    final diff = ((expectedEndAtMs - nowMs) / 1000).ceil();
    return diff < 0 ? 0 : diff;
  }

  ExamSession copyWith({
    Map<int, int>? mcqAnswers,
    Set<int>? mcqFlagged,
    Map<int, String>? termAnswers,
    Set<int>? termFlagged,
    String? enViAnswer,
    String? viEnAnswer,
    bool? isSubmitted,
  }) {
    return ExamSession(
      id: id,
      startedAtMs: startedAtMs,
      expectedEndAtMs: expectedEndAtMs,
      mcqIds: mcqIds,
      mcqOptionOrders: mcqOptionOrders,
      mcqAnswers: mcqAnswers ?? this.mcqAnswers,
      mcqFlagged: mcqFlagged ?? this.mcqFlagged,
      termIds: termIds,
      termAnswers: termAnswers ?? this.termAnswers,
      termFlagged: termFlagged ?? this.termFlagged,
      enViParagraphId: enViParagraphId,
      enViAnswer: enViAnswer ?? this.enViAnswer,
      viEnParagraphId: viEnParagraphId,
      viEnAnswer: viEnAnswer ?? this.viEnAnswer,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAtMs': startedAtMs,
        'expectedEndAtMs': expectedEndAtMs,
        'mcqIds': mcqIds,
        'mcqOptionOrders': mcqOptionOrders,
        'mcqAnswers': mcqAnswers.map((k, v) => MapEntry(k.toString(), v)),
        'mcqFlagged': mcqFlagged.toList(),
        'termIds': termIds,
        'termAnswers': termAnswers.map((k, v) => MapEntry(k.toString(), v)),
        'termFlagged': termFlagged.toList(),
        'enViParagraphId': enViParagraphId,
        'enViAnswer': enViAnswer,
        'viEnParagraphId': viEnParagraphId,
        'viEnAnswer': viEnAnswer,
        'isSubmitted': isSubmitted,
      };

  factory ExamSession.fromJson(Map<String, dynamic> json) {
    final rawMcqAns = json['mcqAnswers'] as Map<String, dynamic>? ?? {};
    final rawTermAns = json['termAnswers'] as Map<String, dynamic>? ?? {};
    return ExamSession(
      id: json['id'] as String,
      startedAtMs: json['startedAtMs'] as int,
      expectedEndAtMs: json['expectedEndAtMs'] as int,
      mcqIds: List<String>.from(json['mcqIds'] as List),
      mcqOptionOrders: (json['mcqOptionOrders'] as List)
          .map((e) => List<int>.from(e as List))
          .toList(),
      mcqAnswers:
          rawMcqAns.map((k, v) => MapEntry(int.parse(k), v as int)),
      mcqFlagged: Set<int>.from(json['mcqFlagged'] as List? ?? []),
      termIds: List<String>.from(json['termIds'] as List),
      termAnswers:
          rawTermAns.map((k, v) => MapEntry(int.parse(k), v as String)),
      termFlagged: Set<int>.from(json['termFlagged'] as List? ?? []),
      enViParagraphId: json['enViParagraphId'] as String,
      enViAnswer: json['enViAnswer'] as String? ?? '',
      viEnParagraphId: json['viEnParagraphId'] as String,
      viEnAnswer: json['viEnAnswer'] as String? ?? '',
      isSubmitted: json['isSubmitted'] as bool? ?? false,
    );
  }
}
