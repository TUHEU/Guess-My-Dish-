import 'enums.dart';

class Paper {
  final String id;
  final String title;
  final String subject;
  final UniversityLevel level;
  final String year;
  final String uploaderId;
  final String uploaderName;
  final ContentType contentType;
  String status;
  final String fileType;
  final DateTime uploadDate;
  final String? description;
  final List<String> tags;
  final int downloadCount;
  String? rejectionReason;
  final String filePath;

  Paper({
    required this.id,
    required this.title,
    required this.subject,
    required this.level,
    required this.year,
    required this.uploaderId,
    required this.uploaderName,
    required this.contentType,
    required this.status,
    required this.fileType,
    required this.uploadDate,
    this.description,
    this.tags = const [],
    this.downloadCount = 0,
    this.rejectionReason,
    required this.filePath,
  });

  String get levelString {
    switch (level) {
      case UniversityLevel.level1:
        return 'Level 1';
      case UniversityLevel.level2:
        return 'Level 2';
      case UniversityLevel.level3:
        return 'Level 3';
      case UniversityLevel.level4:
        return 'Level 4';
    }
  }

  String get contentTypeString {
    switch (contentType) {
      case ContentType.pastPaper:
        return 'Past Paper';
      case ContentType.notes:
        return 'Study Notes';
      case ContentType.answerSheet:
        return 'Answer Sheet';
      case ContentType.quiz:
        return 'Quiz';
    }
  }
}
