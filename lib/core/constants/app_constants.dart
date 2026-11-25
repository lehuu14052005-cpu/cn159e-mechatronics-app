import '../../models/chapter.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'CN159E – Mechatronics English';
  static const String appShortName = 'CN159E';
  static const String appSubtitle = 'Anh văn chuyên môn Cơ điện tử';
  static const String appVersion = '1.0.0';

  // Exam structure constants (strictly fixed per specification)
  static const int examDurationMinutes = 90;
  static const int examDurationSeconds = examDurationMinutes * 60; // 5400s
  static const int part1McqCount = 20;
  static const double part1PointsPerQuestion = 0.125;
  static const double part1MaxScore = 2.5;

  static const int part2TermCount = 10;
  static const double part2PointsPerTerm = 0.25;
  static const double part2MaxScore = 2.5;

  static const int part3EnViCount = 1;
  static const double part3MaxScore = 2.5;

  static const int part4ViEnCount = 1;
  static const double part4MaxScore = 2.5;

  static const double totalMaxScore = 10.0;

  // Timer warning thresholds in seconds
  static const int warn15MinSeconds = 15 * 60;
  static const int warn5MinSeconds = 5 * 60;
  static const int warn1MinSeconds = 1 * 60;

  static const List<ChapterInfo> chapters = [
    ChapterInfo(
      id: 'ch4',
      code: 'Chapter 4',
      title: 'Actuators',
      vietnameseTitle: 'Cơ cấu chấp hành',
      description:
          'Pneumatic, hydraulic, electric actuators, operating principles, components, and applications.',
      iconName: 'precision_manufacturing',
      colorHex: 0xFF1565C0,
    ),
    ChapterInfo(
      id: 'ch5_1',
      code: 'Chapter 5.1',
      title: 'Control System',
      vietnameseTitle: 'Hệ thống điều khiển',
      description:
          'Open-loop, closed-loop, step response, self-regulation, P/I systems, dead time, energy storage.',
      iconName: 'tune',
      colorHex: 0xFF00838F,
    ),
    ChapterInfo(
      id: 'ch5_2',
      code: 'Chapter 5.2',
      title: 'Microcontroller',
      vietnameseTitle: 'Vi điều khiển',
      description:
          'MCU architecture, CPU, data/program memory, I/O peripherals, 8/16/32-bit, Arduino Uno.',
      iconName: 'memory',
      colorHex: 0xFF283593,
    ),
    ChapterInfo(
      id: 'ch6',
      code: 'Chapter 6',
      title: 'Internet of Things',
      vietnameseTitle: 'Internet vạn vật (IoT)',
      description:
          'IoT concepts, 4-layer architecture: perception, network (DAS, MQTT), data processing, UI.',
      iconName: 'hub',
      colorHex: 0xFF0277BD,
    ),
  ];

  static ChapterInfo getChapter(String id) {
    return chapters.firstWhere(
      (c) => c.id == id,
      orElse: () => chapters.first,
    );
  }

  static String getGradeLabel(double score) {
    if (score >= 9.0) return 'Excellent';
    if (score >= 8.0) return 'Very Good';
    if (score >= 7.0) return 'Good';
    if (score >= 5.0) return 'Average';
    return 'Need More Practice';
  }
}
