class ChapterDetailsModel {
  final String boardName;
  final String className;
  final String subjectName;
  final String chapterName;
  final String imageUrl;
  final List<ChapterDetailItem> chapterDetails;

  ChapterDetailsModel({
    required this.boardName,
    required this.className,
    required this.subjectName,
    required this.chapterName,
    required this.imageUrl,
    required this.chapterDetails,
  });

  factory ChapterDetailsModel.fromJson(Map<String, dynamic> json) {
    return ChapterDetailsModel(
      boardName: json['boardName'],
      className: json['className'],
      subjectName: json['subjectName'],
      chapterName: json['chapterName'],
      imageUrl: json['imageurl'],
      chapterDetails: List<ChapterDetailItem>.from(
        json['chapter_detail'].map((x) => ChapterDetailItem.fromJson(x)),
      ),
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
  });

  factory ChapterDetailItem.fromJson(Map<String, dynamic> json) {
    return ChapterDetailItem(
      id: json['id'],
      boardId: json['board_id'],
      boardClassId: json['boardclass_id'],
      boardSubjectId: json['boardsubject_id'],
      chapterId: json['chapter_id'],
      type: json['type'],
      headingName: json['heding_name'],
      image: json['image'],
      content: json['content'],
      status: json['status'],
    );
  }
}
