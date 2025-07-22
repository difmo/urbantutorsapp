class GetChapterModel {
  final bool success;
  final List<ChapterData> data;
  final String message;

  GetChapterModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory GetChapterModel.fromJson(Map<String, dynamic> json) {
    return GetChapterModel(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>)
          .map((e) => ChapterData.fromJson(e))
          .toList(),
      message: json['message'] ?? '',
    );
  }
}
 class ChapterData{
  final int boardId;
  final int classId;
  final int subjectId;
  final int chapterId;
  final String chapterName;
  final String type;

  ChapterData({
    required this.boardId,
    required this.classId,
    required this.subjectId,
    required this.chapterId,
    required this.chapterName,
    required this .type,
  });

  factory ChapterData.fromJson(Map<String, dynamic> json) {
    return ChapterData(boardId: json['board_id'] ?? 0,
      classId: json['class_id'] ?? 0,
      subjectId: json['subject_id'] ?? 0,
      chapterId: json['chapter_id'] ?? 0,
      chapterName: json['ChapterName'] ?? '',
      type: json['type'] ?? '',);
  }
 }