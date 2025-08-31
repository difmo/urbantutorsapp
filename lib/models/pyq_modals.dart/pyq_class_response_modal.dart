class ClassResponse {
  final bool success;
  final List<ClassData> data;
  final String message;

  ClassResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ClassResponse.fromJson(Map<String, dynamic> json) {
    return ClassResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ClassData.fromJson(e))
              .toList() ??
          [],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class ClassData {
  final int boardId;
  final int classId;
  final String className;
  final String type;

  ClassData({
    required this.boardId,
    required this.classId,
    required this.className,
    required this.type,
  });

  factory ClassData.fromJson(Map<String, dynamic> json) {
    return ClassData(
      boardId: json['board_id'] ?? 0,
      classId: json['class_id'] ?? 0,
      className: json['ClassName'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board_id': boardId,
      'class_id': classId,
      'ClassName': className,
      'type': type,
    };
  }
}

class SubjectResponse {
  final bool success;
  final List<SubjectData> data;
  final String message;

  SubjectResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory SubjectResponse.fromJson(Map<String, dynamic> json) {
    return SubjectResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => SubjectData.fromJson(e))
              .toList() ??
          [],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class SubjectData {
  final int boardId;
  final int classId;
  final int subjectId;
  final String subjectName;
  final String type;

  SubjectData({
    required this.boardId,
    required this.classId,
    required this.subjectId,
    required this.subjectName,
    required this.type,
  });

  factory SubjectData.fromJson(Map<String, dynamic> json) {
    return SubjectData(
      boardId: json['board_id'] ?? 0,
      classId: json['class_id'] ?? 0,
      subjectId: json['subject_id'] ?? 0,
      subjectName: json['subjectName'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board_id': boardId,
      'class_id': classId,
      'subject_id': subjectId,
      'subjectName': subjectName,
      'type': type,
    };
  }
}

class ChapterResponse {
  final bool success;
  final List<ChapterData> data;
  final String message;

  ChapterResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ChapterResponse.fromJson(Map<String, dynamic> json) {
    return ChapterResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ChapterData.fromJson(e))
              .toList() ??
          [],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class ChapterData {
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
    required this.type,
  });

  factory ChapterData.fromJson(Map<String, dynamic> json) {
    return ChapterData(
      boardId: json['board_id'] ?? 0,
      classId: json['class_id'] ?? 0,
      subjectId: json['subject_id'] ?? 0,
      chapterId: json['chapter_id'] ?? 0,
      chapterName: json['ChapterName'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board_id': boardId,
      'class_id': classId,
      'subject_id': subjectId,
      'chapter_id': chapterId,
      'ChapterName': chapterName,
      'type': type,
    };
  }
}

class ChapterDetailsResponse {
  final bool success;
  final ChapterDetailsData data;
  final String? message;

  ChapterDetailsResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory ChapterDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ChapterDetailsResponse(
      success: json['success'] ?? false,
      data: ChapterDetailsData.fromJson(json['data']),
      message: json['message'],
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
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
