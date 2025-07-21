class GetClassesModel {
  final bool success;
  final List<ClassData> data;
  final String message;

  GetClassesModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory GetClassesModel.fromJson(Map<String, dynamic> json) {
    return GetClassesModel(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>)
          .map((e) => ClassData.fromJson(e))
          .toList(),
      message: json['message'] ?? '',
    );
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
}
