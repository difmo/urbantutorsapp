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
  final int id;
  final String name;

  ClassData({
    required this.id,
    required this.name,
  });

  factory ClassData.fromJson(Map<String, dynamic> json) {
    return ClassData(
      id: json['course_id'] ?? 0,
      name: json['course_name'] ?? '',
    );
  }

  /// Optional: Provide getters for dropdowns
  int get classId => id;
  String get className => name;
}
