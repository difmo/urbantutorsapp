class GetSubjectModel {
  final bool success;
  final List<SubjectData> data;
  final String message;

  GetSubjectModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory GetSubjectModel.fromJson(Map<String, dynamic> json) {
    return GetSubjectModel(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>)
          .map((e) => SubjectData.fromJson(e))
          .toList(),
      message: json['message'] ?? '',
    );
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
}
