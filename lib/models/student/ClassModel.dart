class ClassModel {
  final int boardId;
  final int classId;
  final String className;
  final String type;

  ClassModel({
    required this.boardId,
    required this.classId,
    required this.className,
    required this.type,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      boardId: json['board_id'],
      classId: json['class_id'],
      className: json['ClassName'],
      type: json['type'],
    );
  }
}
