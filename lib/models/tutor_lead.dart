class TutorLead {
  final int id;
  final int userId;
  final String studentName;
  final String boardName;
  final String courseName;
  final String subjectName;
  final String mobile;
  final String price;
  final String state;
  final String location;
  final String mode; // Online/Offline
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TutorLead({
    required this.id,
    required this.userId,
    required this.studentName,
    required this.boardName,
    required this.courseName,
    required this.subjectName,
    required this.mobile,
    required this.price,
    required this.state,
    required this.location,
    required this.mode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TutorLead.fromJson(Map<String, dynamic> j) => TutorLead(
        id: j['id'] ?? 0,
        userId: j['user_id'] ?? 0,
        studentName: (j['student_name'] ?? '').toString(),
        boardName: (j['board_name'] ?? '').toString(),
        courseName: (j['course_name'] ?? '').toString(),
        subjectName: (j['subject_name'] ?? '').toString(),
        mobile: (j['mobile'] ?? '').toString(),
        price: (j['price'] ?? '').toString(),
        state: (j['state'] ?? '').toString(),
        location: (j['location'] ?? '').toString(),
        mode: (j['mode'] ?? '').toString(),
        status: j['status'] ?? 0,
        createdAt: j['created_at'] != null ? DateTime.tryParse(j['created_at']) : null,
        updatedAt: j['updated_at'] != null ? DateTime.tryParse(j['updated_at']) : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'student_name': studentName,
        'board_name': boardName,
        'course_name': courseName,
        'subject_name': subjectName,
        'mobile': mobile,
        'price': price,
        'state': state,
        'location': location,
        'mode': mode,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
