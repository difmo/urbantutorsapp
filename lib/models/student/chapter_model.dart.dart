class ChapterModel {
  final int boardId;
  final int classId;
  final int subjectId;
  final int chapterId;
  final String chapterName;
  final String type;

  ChapterModel({
    required this.boardId,
    required this.classId,
    required this.subjectId,
    required this.chapterId,
    required this.chapterName,
    required this.type,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      boardId: json['board_id'],
      classId: json['class_id'],
      subjectId: json['subject_id'],
      chapterId: json['chapter_id'],
      chapterName: json['ChapterName'],
      type: json['type'],
    );
  }
}
