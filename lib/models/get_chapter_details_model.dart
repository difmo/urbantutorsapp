class GetChapterDetailsModel {
  final bool success;
  final ChapterDetailsData data;
  final String message;

  GetChapterDetailsModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory GetChapterDetailsModel.fromJson(Map<String, dynamic> json) {
    return GetChapterDetailsModel(
      success: json['success'] ?? false,
      data: ChapterDetailsData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class ChapterDetailsData {
  final String boardName;
  final String className;
  final String subjectName;
  final String chapterName;
  final String imageUrl;
  final List<ChapterDetailItem> chapterDetail;

  ChapterDetailsData({
    required this.boardName,
    required this.className,
    required this.subjectName,
    required this.chapterName,
    required this.imageUrl,
    required this.chapterDetail,
  });

  factory ChapterDetailsData.fromJson(Map<String, dynamic> json) {
    return ChapterDetailsData(
      boardName: json['boardName'] ?? '',
      className: json['className'] ?? '',
      subjectName: json['subjectName'] ?? '',
      chapterName: json['chapterName'] ?? '',
      imageUrl: json['imageurl'] ?? '',
      chapterDetail: (json['chapter_detail'] as List<dynamic>)
          .map((e) => ChapterDetailItem.fromJson(e))
          .toList(),
    );
  }
}

class ChapterDetailItem {
  final int id;
  final int boardId;
  final int boardClassId;
  final int boardSubjectId;
  final int chapterId;
  final String type;
  final String headingName;
  final String image;
  final String content;
  final int status;
  final String createdAt;
  final String updatedAt;

  ChapterDetailItem({
    required this.id,
    required this.boardId,
    required this.boardClassId,
    required this.boardSubjectId,
    required this.chapterId,
    required this.type,
    required this.headingName,
    required this.image,
    required this.content,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChapterDetailItem.fromJson(Map<String, dynamic> json) {
    return ChapterDetailItem(
      id: json['id'] ?? 0,
      boardId: json['board_id'] ?? 0,
      boardClassId: json['boardclass_id'] ?? 0,
      boardSubjectId: json['boardsubject_id'] ?? 0,
      chapterId: json['chapter_id'] ?? 0,
      type: json['type'] ?? '',
      headingName: json['heding_name'] ?? '',
      image: json['image'] ?? '',
      content: json['content'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
