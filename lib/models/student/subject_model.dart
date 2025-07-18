class SubjectModel {
  final int id;
  final int boardId;
  final int classId;
  final String subjectName;
  final String type;

  SubjectModel({
    required this.id,
    required this.boardId,
    required this.classId,
    required this.subjectName,
    required this.type,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'],
      boardId: json['board_id'],
      classId: json['class_id'],
      subjectName: json['subjectName'],
      type: json['type'],
    );
  }
}
