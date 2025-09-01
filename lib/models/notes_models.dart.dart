class NotesClass {
  final int board_id;
  final int class_id;
  final String ClassName;
  final String type;
  NotesClass({
    required this.board_id,
    required this.class_id,
    required this.ClassName,
    required this.type,
  });

  factory NotesClass.fromJson(Map<String, dynamic> j) {
    int _id(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    return NotesClass(
      board_id: _id(j['board_id']),
      class_id: _id(j['class_id']),
      ClassName: (j['ClassName'] ?? j['class_name'] ?? '').toString(),
      type: (j['type'] ?? '').toString(),
    );
  }
}

class NotesSubject {
  final int boardId;
  final int classId;
  final int subjectId;
  final String subjectName;
  final String type;

  NotesSubject({
    required this.boardId,
    required this.classId,
    required this.subjectId,
    required this.subjectName,
    required this.type,
  });

  factory NotesSubject.fromJson(Map<String, dynamic> j) {
    int _id(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    return NotesSubject(
      boardId: _id(j['board_id']),
      classId: _id(j['class_id']),
      subjectId: _id(j['subject_id']),
      subjectName: (j['subjectName'] ?? j['subject_name'] ?? '').toString(),
      type: (j['type'] ?? '').toString(),
    );
  }
}

class NotesChapter {
  final int boardId;
  final int classId;
  final int subjectId;
  final int chapterId;
  final String chapterName;
  final String type;

  NotesChapter({
    required this.boardId,
    required this.classId,
    required this.subjectId,
    required this.chapterId,
    required this.chapterName,
    required this.type,
  });

  factory NotesChapter.fromJson(Map<String, dynamic> j) {
    int _id(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    return NotesChapter(
      boardId: _id(j['board_id']),
      classId: _id(j['class_id']),
      subjectId: _id(j['subject_id']),
      chapterId: _id(j['chapter_id']),
      chapterName: (j['ChapterName'] ?? j['chapter_name'] ?? '').toString(),
      type: (j['type'] ?? '').toString(),
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
  final String heading; // heding_name
  final String image; // filename
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
    required this.heading,
    required this.image,
    required this.content,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChapterDetailItem.fromJson(Map<String, dynamic> j) {
    int _id(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    return ChapterDetailItem(
      id: _id(j['id']),
      boardId: _id(j['board_id']),
      boardClassId: _id(j['boardclass_id']),
      boardSubjectId: _id(j['boardsubject_id']),
      chapterId: _id(j['chapter_id']),
      type: (j['type'] ?? '').toString(),
      heading: (j['heding_name'] ?? j['heading_name'] ?? '').toString(),
      image: (j['image'] ?? '').toString(),
      content: (j['content'] ?? '').toString(),
      status: _id(j['status']),
      createdAt: (j['created_at'] ?? '').toString(),
      updatedAt: (j['updated_at'] ?? '').toString(),
    );
  }
}

class ChapterDetails {
  final String ?boardName;
  final String ?className;
  final String ?subjectName;
  final String ?chapterName;
  final String ?imageBaseUrl; // imageurl
  final List<ChapterDetailItem> ?items;

  ChapterDetails({
this.boardName,
     this.className,
    this.subjectName,
     this.chapterName,
     this.imageBaseUrl,
   this.items,
  });

  factory ChapterDetails.fromJson(Map<String, dynamic> j) {
    final list = (j['chapter_detail'] as List<dynamic>? ?? [])
        .map((e) => ChapterDetailItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return ChapterDetails(
      boardName: (j['boardName'] ?? '').toString(),
      className: (j['className'] ?? '').toString(),
      subjectName: (j['subjectName'] ?? '').toString(),
      chapterName: (j['chapterName'] ?? '').toString(),
      imageBaseUrl: (j['imageurl'] ?? '').toString(),
      items: list,
    );
  }
}
